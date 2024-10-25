/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 An object that provides the interface to the features of the camera.
 */

import SwiftUI
import Combine

/// An object that provides the interface to the features of the camera.
///
/// This object provides the default implementation of the `Camera` protocol, which defines the interface
/// to configure the camera hardware and capture media. `CameraModel` doesn't perform capture itself, but is an
/// `@Observable` type that mediates interactions between the app's SwiftUI views and `CaptureService`.
///
/// For SwiftUI previews and Simulator, the app uses `PreviewCameraModel` instead.
///
@Observable
final class CameraModel: Camera {
    // MARK: - Properties
    /// The current status of the camera.
    private(set) var status = CameraStatus.unknown
    
    /// The current state of photo capture.
    private(set) var captureActivity = CaptureActivity.idle
    
    /// The photo features that can be enabled in the UI.
    private(set) var photoFeatures = PhotoFeatures()
    
    /// Indicates if the app is switching video devices.
    private(set) var isSwitchingVideoDevices = false
    
    /// Indicates if the app is switching capture modes.
    private(set) var isSwitchingModes = false
    
    /// Indicates if visual feedback should be shown when capture begins.
    private(set) var shouldFlashScreen = false
    
    /// A thumbnail for the last captured photo.
    private(set) var thumbnail: CGImage?
    
    /// An error that indicates details of an error during photo capture.
    private(set) var error: Error?
    
    /// Connects the preview view with the capture session.
    var previewSource: PreviewSource { captureService.previewSource }
    
    /// Indicates if HDR video recording is supported.
    private(set) var isHDRVideoSupported = false
    
    /// Saves captured media to the user's Photos library.
    private let mediaLibrary = MediaLibrary()
    
    /// Manages the app's capture functionality.
    private let captureService = CaptureService()
    
    /// Indicates if the torch (flashlight) is on.
    var isTorchOn: Bool = false
    
    /// Number of camera zoom factor
    private(set) var zoomFactor: CGFloat = 2.0
    
    /// Machine Learning Layer
    var mlcLayer: MachineLearningClassificationLayer?
   
    /// The boolean value of framing carousel
    var isFramingCarouselEnabled: Bool = false
    
    /// The minimum zoom factor.
    var minZoomFactor: CGFloat = 1.0

    /// The maximum zoom factor.
    var maxZoomFactor: CGFloat = 10.0
    
    /// The current aspect ratio
    var aspectRatio: AspectRatio = CGSize(width: 3, height: 4)
    
    // MARK: - Compositions
    
    var compositions: [Composition]
    var activeID: UUID? = nil
    var activeComposition: String = "CENTER"
    
    // MARK: - Initialization
    
    init() {
        compositions = [
            Composition(name: "CENTER", description: "", image: "center_default", isRecommended: false, imageRecommended: "center_default_recommend", imageSelected: "center_selected", imageSelectedRecommended: "center_selected_recommend"),
            Composition(name: "CURVED", description: "", image: "curved_default", isRecommended: false, imageRecommended: "curved_default_recommend", imageSelected: "curved_selected", imageSelectedRecommended: "curved_selected_recommend"),
            Composition(name: "DIAGONAL", description: "", image: "diagonal_default", isRecommended: false, imageRecommended: "diagonal_default_recommend", imageSelected: "diagonal_selected", imageSelectedRecommended: "diagonal_selected_recommend"),
            Composition(name: "GOLDEN RATIO", description: "", image: "golden_default", isRecommended: false, imageRecommended: "golden_default_recommend", imageSelected: "golden_selected", imageSelectedRecommended: "golden_selected_recommend"),
            Composition(name: "RULE OF THIRDS", description: "", image: "rot_default", isRecommended: false, imageRecommended: "rot_default_recommend", imageSelected: "rot_selected", imageSelectedRecommended: "rot_selected_recommend"),
            Composition(name: "SYMMETRIC", description: "", image: "symmetric_default", isRecommended: false, imageRecommended: "symmetric_default_recommend", imageSelected: "symmetric_selected", imageSelectedRecommended: "symmetric_selected_recommend"),
            Composition(name: "TRIANGLE", description: "", image: "triangle_default", isRecommended: false, imageRecommended: "triangle_default_recommend", imageSelected: "triangle_selected", imageSelectedRecommended: "triangle_selected_recommend")
        ]
        
        // Initialize active composition ID.
        activeID = compositions.first!.id
        
        // Load machine learning layer asynchronously.
        Task {
            await loadMLLayer()
            await updateZoomFactors()
        }
    }
    
    // MARK: - Starting the Camera
    
    /// Starts the camera and begins the stream of data.
    func start() async {
        guard await captureService.isAuthorized else {
            status = .unauthorized
            return
        }
        do {
            try await captureService.start()
            await updateZoomFactors() // Update zoom factors
            observeState()
            status = .running
        } catch {
            logger.error("Failed to start capture service. \(error)")
            status = .failed
        }
    }
    
    // MARK: - Changing Modes and Devices
    
    /// Selects the next available video device for capture.
    func switchVideoDevices() async {
        isSwitchingVideoDevices = true
        defer { isSwitchingVideoDevices = false }
        await captureService.selectNextVideoDevice()
    }
    
    // MARK: - Photo Capture
    
    /// Toggles the torch (flashlight) on or off.
    func toggleTorch() async {
        isTorchOn = await captureService.toggleTorch()
    }
    
    /// Captures a photo and writes it to the user's Photos library.
    func capturePhoto() async {
        do {
            let photo = try await captureService.capturePhoto(with: photoFeatures.current)
            try await mediaLibrary.save(photo: photo)
        } catch {
            self.error = error
        }
    }
    
    /// Performs a focus and expose operation at the specified screen point.
    func focusAndExpose(at point: CGPoint) async {
        await captureService.focusAndExpose(at: point)
    }
    
    /// Provides visual feedback indicating that capture is starting.
    private func flashScreen() {
        shouldFlashScreen = true
        withAnimation(.linear(duration: 0.01)) {
            shouldFlashScreen = false
        }
    }
    
    // MARK: - Internal State Observations
    
    /// Sets up camera's state observations.
    private func observeState() {
        Task {
            for await thumbnail in mediaLibrary.thumbnails.compactMap({ $0 }) {
                self.thumbnail = thumbnail
            }
        }
        
        Task {
            for await activity in await captureService.$captureActivity.values {
                if activity.willCapture {
                    flashScreen()
                } else {
                    captureActivity = activity
                }
            }
        }
        
        Task {
            for await capabilities in await captureService.$captureCapabilities.values {
                isHDRVideoSupported = capabilities.isHDRSupported
            }
        }
    }
    
    /// Loads the machine learning classification layer.
    private func loadMLLayer() async {
        mlcLayer = await captureService.getMLLayer()
    }
    
    /// Toggle Carousel UI state
    func toggleFramingCarousel() {
        self.isFramingCarouselEnabled.toggle()
    }
}

// MARK: - Extensions

extension CameraModel {
    
    /// Finds a composition based on the machine learning prediction.
    func findComposition(withName name: String) {
        if let index = compositions.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
            compositions[index].isRecommended = true
            for i in 0..<compositions.count {
                if i != index {
                    compositions[i].isRecommended = false
                }
            }
        }
    }
    
    /// Updates the active composition based on the selected UUID.
    func updateActiveComposition(id: UUID?) {
        if let id = id {
            if let composition = compositions.first(where: { $0.id == id }) {
                activeComposition = composition.name
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

extension CameraModel {
    /// Adjusts the zoom based on the given factor.
    func zoom(factor: CGFloat) async -> CGFloat {
        let currentZoomFactor = await captureService.getZoomFactor()
        let (minZoom, maxZoom) = await captureService.getZoomFactors()
        let newZoomFactor = currentZoomFactor * factor
        let clampedZoomFactor = max(minZoom, min(newZoomFactor, maxZoom))
        await zoomFactor = captureService.setZoomFactor(clampedZoomFactor)
        return clampedZoomFactor
    }

    /// Sets the zoom factor directly.
    func setZoomFactor(_ factor: CGFloat) async -> CGFloat {
        let (minZoom, maxZoom) = await captureService.getZoomFactors()
        let clampedZoomFactor = max(minZoom, min(factor, maxZoom))
        await zoomFactor = captureService.setZoomFactor(clampedZoomFactor)
        return clampedZoomFactor
    }

    /// Updates the minimum and maximum zoom factors from the capture service.
    func updateZoomFactors() async {
        let (minZoom, maxZoom) = await captureService.getZoomFactors()
        minZoomFactor = minZoom
        maxZoomFactor = maxZoom
    }
}
