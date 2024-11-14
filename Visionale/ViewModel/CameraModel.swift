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
    var aspectRatio: AspectRatio {
        return self.photoFeatures.aspectRatio
    }
    
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
    var mlcLayer: ImageClassificationHandler?
    
    /// The boolean value of framing carousel
    var isFramingCarouselEnabled: Bool = false
    
    /// The minimum zoom factor.
    var minZoomFactor: CGFloat = 1.0
    
    /// The maximum zoom factor.
    var maxZoomFactor: CGFloat = 6.0
    
    /// The current aspect ratio
    var isAspectRatioOptionEnabled: Bool = false
    
    var videoSwitchZoomFactors: [NSNumber] = []
    
    func toggleAspectRatioOption() {
        isAspectRatioOptionEnabled.toggle()
    }
    
    var isZoomSliderEnabled: Bool = false
    
    // MARK: - Compositions
    
    var compositions: [Composition] = [
        Composition(name: "CENTER", description: "", image: "center", isRecommended: false),
        Composition(name: "LEADING LINE", description: "", image: "leading", isRecommended: false),
        Composition(name: "GOLDEN RATIO", description: "", image: "golden", isRecommended: false),
        Composition(name: "RULE OF THIRDS", description: "", image: "rot", isRecommended: false),
    ]
    
    
    var activeComposition: String = "CENTER"
    var grOrientation: GoldenRatioOrientation = .bottomLeft
    
    // MARK: - Initialization
    private func updateVideoSwitchZoomFactors() async {
        await self.videoSwitchZoomFactors = captureService.virtualDeviceZoomSwitch
    }
    
    init() {
        Task {
            await loadMLLayer()
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
            await updateMaxZoomFactors()
            await updateVideoSwitchZoomFactors()
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
        await updateVideoSwitchZoomFactors()
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
        if let index = compositions.firstIndex(where: { $0.name.lowercased() == name.lowercased().replacingOccurrences(of: "_", with: " ") }) {
            compositions[index].isRecommended = true
            for i in 0..<compositions.count {
                if i != index {
                    compositions[i].isRecommended = false
                }
            }
        }
    }
    
    /// Updates the active composition based on the selected UUID.
    func updateActiveComposition(_ name: String) {
        if let composition = compositions.first(where: { $0.name == name }) {
            activeComposition = composition.name
            switch activeComposition {
            case "CENTER":
                mlcLayer?.setGuidanceSystem(CenterGuidance())
            case "LEADING LINE":
                mlcLayer?.setGuidanceSystem(LeadingLineGuidance())
            case "GOLDEN RATIO":
                mlcLayer?.setGuidanceSystem(GoldenRatioGuidance(
                    aspectRatio: self.photoFeatures.aspectRatio.size.width / self.photoFeatures.aspectRatio.size.height,
                    orientation: .bottomLeft
                ))
            case "RULE OF THIRDS":
                mlcLayer?.setGuidanceSystem(RuleOfThirdsGuidance())
//            case "SYMMETRIC":
//                mlcLayer?.setGuidanceSystem(nil)
            default:
                mlcLayer?.setGuidanceSystem(nil)
            }
        }
        // Haptic
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func changeGoldenRatioOrientation(orientation: GoldenRatioOrientation) {
        self.grOrientation = orientation
        self.mlcLayer?.setGuidanceSystem(GoldenRatioGuidance(
            aspectRatio: self.photoFeatures.aspectRatio.size.width / self.photoFeatures.aspectRatio.size.height,
            orientation: orientation
        ))
    }
}

extension CameraModel {
    /// Adjusts the zoom based on the given factor.
    func setZoom(factor: CGFloat) async {
        let clampedFactor = max(minZoomFactor, min(factor, maxZoomFactor))
        zoomFactor = await captureService.setZoomFactor(clampedFactor)
    }
    
    /// Updates the maximum zoom factor from the capture service.
    func updateMaxZoomFactors() async {
        maxZoomFactor = await captureService.getRecommendedMaxZoomFactor()
    }
}

extension CameraModel {
    func toggleAspectRatio() {
        self.photoFeatures.aspectRatio = AspectRatio.next(after: self.photoFeatures.aspectRatio)
    }
}
/// Supported aspect ratios.
enum AspectRatio: CaseIterable {
    case ratio4_3
    case ratio16_9
    case ratio1_1
    
    var size: CGSize {
        switch self {
        case .ratio4_3:
            return CGSize(width: 3, height: 4)
        case .ratio16_9:
            return CGSize(width: 9, height: 16)
        case .ratio1_1:
            return CGSize(width: 1, height: 1)
        }
    }
    
    var value: CGFloat {
        return size.width / size.height
    }
    
    var description: String {
        switch self {
        case .ratio4_3:
            return "4:3"
        case .ratio16_9:
            return "16:9"
        case .ratio1_1:
            return "1:1"
        }
    }
    
    /// Get the next aspect ratio in the sequence.
    static func next(after current: AspectRatio) -> AspectRatio {
        let all = AspectRatio.allCases
        if let index = all.firstIndex(of: current), index + 1 < all.count {
            return all[index + 1]
        } else {
            return all.first!
        }
    }
}
