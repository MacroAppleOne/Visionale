/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 An object that manages a capture session and its inputs and outputs.
 */

import Foundation
import AVFoundation
import Combine

/// An actor that manages the capture pipeline, which includes the capture session, device inputs, and capture outputs.
/// The app defines it as an `actor` type to ensure that all camera operations happen off of the `@MainActor`.
/// An actor that manages the camera capture session and related functionalities.
actor CaptureService {
    // MARK: - Published Properties
    
    /// Indicates the current capture activity (idle or capturing a photo).
    @Published private(set) var captureActivity: CaptureActivity = .idle
    
    /// Indicates the current capture capabilities of the service.
    @Published private(set) var captureCapabilities = CaptureCapabilities.unknown
    
    /// Indicates if the capture session is interrupted by a higher priority event.
    @Published private(set) var isInterrupted = false
    
    @Published private var aspectRatio: CGSize = AspectRatio.ratio4_3.size
    // MARK: - Preview Source
    
    /// Connects a preview destination with the capture session.
    nonisolated let previewSource: PreviewSource
    
    // MARK: - Private Properties
    
    private let captureSession = AVCaptureSession()
    private let photoCapture = PhotoCapture()
    private var outputServices: [any OutputService] { [photoCapture] }
    private var activeVideoInput: AVCaptureDeviceInput?
    private(set) var captureMode = CaptureMode.photo
    private let deviceLookup = DeviceLookup()
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator!
    private var rotationObservers = [AnyObject]()
    private let mlClassificationLayer = ImageClassificationHandler()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var isSetUp = false
    private var zoomFactor: CGFloat = 2.0
    
    // MARK: - Computed Properties
    
    /// The device for the active video input.
    private var currentDevice: AVCaptureDevice? {
        return activeVideoInput?.device
    }
    
    func updateAspectRatio(_ aspectRatio: AspectRatio) {
        self.aspectRatio = aspectRatio.size
    }

    
    // MARK: - Initialization
    
    init() {
        // Create a source object to connect the preview view with the capture session.
        previewSource = DefaultPreviewSource(session: captureSession)
    }
    
    // MARK: - Authorization
    
    /// Checks if the app is authorized to use device cameras.
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    // MARK: - Capture Session Life Cycle
    
    /// Starts the capture session.
    func start() async throws {
        guard await isAuthorized, !captureSession.isRunning else { return }
        try setUpSession()
        captureSession.startRunning()
        setInitialZoom()
//        print(currentDevice?.activeFormat.videoMaxZoomFactor ?? "Blm ada")
    }
    
    // MARK: - Capture Setup
    
    /// Performs the initial capture session configuration.
    private func setUpSession() throws {
        guard !isSetUp else { return }
        observeOutputServices()
        observeNotifications()
        
        do {
            guard let defaultCamera = deviceLookup.cameras.first else {
                throw CameraError.setupFailed
            }
//            defaultCamera.formats.forEach { print($0) }
            activeVideoInput = try addInput(for: defaultCamera)
            captureSession.sessionPreset = .photo
            try addOutput(photoCapture.output)
            addMLVideoOutput()
            createRotationCoordinator(for: defaultCamera)
            observeSubjectAreaChanges(of: defaultCamera)
            updateCaptureCapabilities()
            isSetUp = true
        } catch {
            throw CameraError.setupFailed
        }
    }
    
    /// Adds an input to the capture session for the specified device.
    @discardableResult
    private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        let input = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.addInputFailed
        }
        return input
    }
    
    /// Adds an output to the capture session.
    private func addOutput(_ output: AVCaptureOutput) throws {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            throw CameraError.addOutputFailed
        }
    }
    
    // MARK: Camera Controls
    func setZoomLevel(_ zoom: CGFloat) {
        guard let device = activeVideoInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(zoom, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print("Failed to set zoom level: \(error)")
        }
    }
    
    
    /// Set initial zoom level after the session is running
    private func setInitialZoom() {
        guard let device = activeVideoInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
            // Ensure the zoom factor doesn't exceed the camera's maximum zoom level
            device.videoZoomFactor = max(1.0, min(2.0, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print("Failed to set initial zoom level: \(error)")
        }
    }
    
    /// Returns the recommended maximum zoom factor for the current device.
    func getRecommendedMaxZoomFactor() -> CGFloat {
        guard let currentDevice = currentDevice else { return 0.0 }
        if let lastZoomFactor = currentDevice.virtualDeviceSwitchOverVideoZoomFactors.last as? CGFloat {
            return lastZoomFactor * 10
        } else {
            return min(currentDevice.activeFormat.videoMaxZoomFactor, 6.0)
        }
    }
    
//    func setZoomFactor(_ factor: CGFloat) -> CGFloat{
//        guard let currentDevice = currentDevice else { return factor }
//        do {
//            try currentDevice.lockForConfiguration()
//            let minZoom = currentDevice.minAvailableVideoZoomFactor
//            let maxZoom = getRecommendedMaxZoomFactor()
//            let clampedZoomFactor = max(minZoom, min(factor, maxZoom))
//            currentDevice.videoZoomFactor = clampedZoomFactor
//            currentDevice.unlockForConfiguration()
//            return clampedZoomFactor
//        } catch {
//            print("Failed to set zoom level: \(error)")
//        }
//        return currentDevice.videoZoomFactor
//    }
    
    func setZoomFactor(_ factor: CGFloat) -> CGFloat {
        guard let currentDevice = currentDevice else { return factor }
        do {
            try currentDevice.lockForConfiguration()
            let minZoom = currentDevice.minAvailableVideoZoomFactor
            let maxZoom = getRecommendedMaxZoomFactor()
            let clampedZoomFactor = max(minZoom, min(factor, maxZoom))
            currentDevice.videoZoomFactor = clampedZoomFactor
            currentDevice.unlockForConfiguration()
            return clampedZoomFactor
        } catch {
            print("Failed to set zoom level: \(error)")
            return currentDevice.videoZoomFactor
        }
    }

    // MARK: - Device Selection
    
    /// Changes the capture device that provides video input.
    func selectNextVideoDevice() {
        let videoDevices = deviceLookup.cameras
        guard let currentDevice = currentDevice,
              let selectedIndex = videoDevices.firstIndex(of: currentDevice) else { return }
        
        var nextIndex = selectedIndex + 1
        if nextIndex >= videoDevices.count {
            nextIndex = 0
        }
        
        let nextDevice = videoDevices[nextIndex]
        changeCaptureDevice(to: nextDevice)
        AVCaptureDevice.userPreferredCamera = nextDevice
    }
    
    /// Changes the device the service uses for video capture.
    private func changeCaptureDevice(to device: AVCaptureDevice) {
        guard let currentInput = activeVideoInput else { fatalError("No active video input.") }
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        captureSession.removeInput(currentInput)
        do {
            activeVideoInput = try addInput(for: device)
            createRotationCoordinator(for: device)
            observeSubjectAreaChanges(of: device)
            updateCaptureCapabilities()
        } catch {
            captureSession.addInput(currentInput)
        }
    }
    
    func minMaxCameraDeviceZoomFactor() -> (min: CGFloat, max: CGFloat) {
        guard let device = activeVideoInput?.device else { return (0, 0) }
        return (
            device.minAvailableVideoZoomFactor,
            device.maxAvailableVideoZoomFactor
        )
    }
    
    // MARK: - Rotation Handling
    
    /// Creates a rotation coordinator and observes rotation changes.
    private func createRotationCoordinator(for device: AVCaptureDevice) {
        rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: videoPreviewLayer)
        updatePreviewRotation(rotationCoordinator.videoRotationAngleForHorizonLevelPreview)
        updateCaptureRotation(rotationCoordinator.videoRotationAngleForHorizonLevelCapture)
        rotationObservers.removeAll()
        
        rotationObservers.append(
            rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) { [weak self] _, change in
                guard let self = self, let angle = change.newValue else { return }
                Task {
                    await self.updatePreviewRotation(angle)
                    
                }
            }
        )
        
        rotationObservers.append(
            rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: .new) { [weak self] _, change in
                guard let self = self, let angle = change.newValue else { return }
                Task {
                    await self.updateCaptureRotation(angle)
                }
            }
        )
    }
    
    /// Updates the preview rotation angle.
    private func updatePreviewRotation(_ angle: CGFloat) {
        let previewLayer = videoPreviewLayer
        DispatchQueue.main.async {
            previewLayer.connection?.videoRotationAngle = angle
        }
    }
    
    /// Updates the capture rotation angle.
    private func updateCaptureRotation(_ angle: CGFloat) {
        outputServices.forEach { $0.setVideoRotationAngle(angle) }
    }
    
    /// The video preview layer.
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let previewLayer = captureSession.connections.compactMap({ $0.videoPreviewLayer }).first else {
            fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
        }
        return previewLayer
    }
    
    // MARK: - Automatic Focus and Exposure
    
    /// Performs a one-time automatic focus and expose operation.
    func focusAndExpose(at point: CGPoint) {
        let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
        do {
            try focusAndExpose(at: devicePoint, isUserInitiated: true)
        } catch {
            logger.debug("Unable to perform focus and exposure operation. \(error)")
        }
    }
    
    /// Observes subject area changes for the specified device.
    private func observeSubjectAreaChanges(of device: AVCaptureDevice) {
        subjectAreaChangeTask?.cancel()
        subjectAreaChangeTask = Task {
            for await _ in NotificationCenter.default.notifications(named: AVCaptureDevice.subjectAreaDidChangeNotification, object: device).compactMap({ _ in true }) {
                try? focusAndExpose(at: CGPoint(x: 0.5, y: 0.5), isUserInitiated: false)
            }
        }
    }
    private var subjectAreaChangeTask: Task<Void, Never>?
    
    /// Performs focus and exposure at the specified device point.
    private func focusAndExpose(at devicePoint: CGPoint, isUserInitiated: Bool) throws {
        guard let device = currentDevice else { return }
        try device.lockForConfiguration()
        
        let focusMode: AVCaptureDevice.FocusMode = isUserInitiated ? .autoFocus : .continuousAutoFocus
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
            device.focusPointOfInterest = devicePoint
            device.focusMode = focusMode
        }
        
        let exposureMode: AVCaptureDevice.ExposureMode = isUserInitiated ? .autoExpose : .continuousAutoExposure
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
            device.exposurePointOfInterest = devicePoint
            device.exposureMode = exposureMode
        }
        
        device.isSubjectAreaChangeMonitoringEnabled = isUserInitiated
        device.unlockForConfiguration()
    }
    
    // MARK: - Photo Capture
    
    /// Captures a photo with the specified features.
    func capturePhoto(with features: EnabledPhotoFeatures) async throws -> Photo {
        return try await photoCapture.capturePhoto(with: features)
    }
    
    
    
    // MARK: - Internal State Management
    
    /// Updates the capture capabilities.
    private func updateCaptureCapabilities() {
        if let currentDevice = currentDevice {
            outputServices.forEach { $0.updateConfiguration(for: currentDevice) }
        }
        captureCapabilities = photoCapture.capabilities
    }
    
    /// Observes output service capture activities.
    private func observeOutputServices() {
        photoCapture.$captureActivity
            .assign(to: &$captureActivity)
    }
    
    /// Observes capture-related notifications.
    private func observeNotifications() {
        Task {
            for await reason in NotificationCenter.default.notifications(named: AVCaptureSession.wasInterruptedNotification)
                .compactMap({ $0.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject? })
                .compactMap({ AVCaptureSession.InterruptionReason(rawValue: $0.integerValue) }) {
                isInterrupted = [.audioDeviceInUseByAnotherClient, .videoDeviceInUseByAnotherClient].contains(reason)
            }
        }
        
        Task {
            for await _ in NotificationCenter.default.notifications(named: AVCaptureSession.interruptionEndedNotification) {
                isInterrupted = false
            }
        }
        
        Task {
            for await error in NotificationCenter.default.notifications(named: AVCaptureSession.runtimeErrorNotification)
                .compactMap({ $0.userInfo?[AVCaptureSessionErrorKey] as? AVError }) {
                if error.code == .mediaServicesWereReset {
                    if !captureSession.isRunning {
                        captureSession.startRunning()
                    }
                }
            }
        }
    }
    
    // MARK: - Torch Handling
    
    /// Toggles the torch (flashlight) on or off.
    func toggleTorch() -> Bool {
        guard let device = currentDevice, device.hasTorch else { return false }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            device.unlockForConfiguration()
            return device.torchMode == .on
        } catch {
            print("Failed to toggle torch: \(error)")
            return false
        }
    }
    
    // MARK: - Machine Learning Handling
    
    /// Returns Machine Learning Layer
    func getMLLayer() -> ImageClassificationHandler {
        return mlClassificationLayer
    }
    
    /// Adds video output to capture session for frame processing by machine learning
    private func addMLVideoOutput() {
        /// Set the delegate for frame processing
        videoDataOutput.setSampleBufferDelegate(mlClassificationLayer, queue: DispatchQueue(label: "video_frame_queue"))
        
        /// Ensure the format is compatible with your model's input
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        } else {
            fatalError("Failed to add video output for ML processing.")
        }
    }
}
