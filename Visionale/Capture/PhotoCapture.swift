/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 An object that manages a photo capture output to take photographs.
 */

import AVFoundation
import CoreImage
import UIKit

enum PhotoCaptureError: Error {
    case noPhotoData
}

/// An object that manages a photo capture output to perform take photographs.
final class PhotoCapture: OutputService {
    
    /// A value that indicates the current state of photo capture.
    @Published private(set) var captureActivity: CaptureActivity = .idle
    
    /// The capture output type for this service.
    let output = AVCapturePhotoOutput()
    
    // An internal alias for the output.
    private var photoOutput: AVCapturePhotoOutput { output }
    
    // The current capabilities available.
    private(set) var capabilities: CaptureCapabilities = .unknown
    
    // A count of Live Photo captures currently in progress.
    private var livePhotoCount = 0
    
    // MARK: - Capture a photo.
    
    /// The app calls this method when the user taps the photo capture button.
    func capturePhoto(with features: EnabledPhotoFeatures) async throws -> Photo {
        // Wrap the delegate-based capture API in a continuation to use it in an async context.
        
        
        try await withCheckedThrowingContinuation { continuation in
            
            // Create a settings object to configure the photo capture.
            let photoSettings = createPhotoSettings(with: features)
            
            let delegate = PhotoCaptureDelegate(continuation: continuation, features: features)
            monitorProgress(of: delegate)
            
            // Capture a new photo with the specified settings.
            photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        }
    }
    
    // MARK: - Create a photo settings object.
    
    // Create a photo settings object with the features a person enables in the UI.
    private func createPhotoSettings(with features: EnabledPhotoFeatures) -> AVCapturePhotoSettings {
        // Create a new settings object to configure the photo capture.
        var photoSettings = AVCapturePhotoSettings()
        
        // Capture photos in HEIF format when the device supports it.
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        /// Set the format of the preview image to capture. The `photoSettings` object returns the available
        /// preview format types in order of compatibility with the primary image.
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        /// Set the largest dimensions that the photo output supports.
        /// `CaptureService` automatically updates the photo output's `maxPhotoDimensions`
        /// when the capture pipeline changes.
        photoSettings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        
        // Set the flash mode.
        photoSettings.flashMode = features.isFlashEnabled ? .auto : .off
        
        // Set the movie URL if the photo output supports Live Photo capture.
        photoSettings.livePhotoMovieFileURL = features.isLivePhotoEnabled ? URL.movieFileURL : nil
        
        // Set the priority of speed versus quality during this capture.
        if let prioritization = AVCapturePhotoOutput.QualityPrioritization(rawValue: features.qualityPrioritization.rawValue) {
            photoSettings.photoQualityPrioritization = prioritization
        }
        
        
        return photoSettings
    }
    
    /// Monitors the progress of a photo capture delegate.
    ///
    /// The `PhotoCaptureDelegate` produces an asynchronous stream of values that indicate its current activity.
    /// The app propagates the activity values up to the view tier so the UI can update accordingly.
    private func monitorProgress(of delegate: PhotoCaptureDelegate, isolation: isolated (any Actor)? = #isolation) {
        Task {
            _ = isolation
            var isLivePhoto = false
            // Asynchronously monitor the activity of the delegate while the system performs capture.
            for await activity in delegate.activityStream {
                var currentActivity = activity
                /// More than one activity value for the delegate may report that `isLivePhoto` is `true`.
                /// Only increment/decrement the count when the value changes from its previous state.
                if activity.isLivePhoto != isLivePhoto {
                    isLivePhoto = activity.isLivePhoto
                    // Increment or decrement as appropriate.
                    livePhotoCount += isLivePhoto ? 1 : -1
                    if livePhotoCount > 1 {
                        /// Set `isLivePhoto` to `true` when there are concurrent Live Photos in progress.
                        /// This prevents the "Live" badge in the UI from flickering.
                        currentActivity = .photoCapture(willCapture: activity.willCapture, isLivePhoto: true)
                    }
                }
                captureActivity = currentActivity
            }
        }
    }
    
    // MARK: - Update the photo output configuration
    
    /// Reconfigures the photo output and updates the output service's capabilities accordingly.
    ///
    /// The `CaptureService` calls this method whenever you change cameras.
    ///
    func updateConfiguration(for device: AVCaptureDevice) {
        // Enable all supported features.
        photoOutput.maxPhotoDimensions = device.activeFormat.supportedMaxPhotoDimensions.last ?? .zero
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        photoOutput.maxPhotoQualityPrioritization = .quality
        photoOutput.isResponsiveCaptureEnabled = photoOutput.isResponsiveCaptureSupported
        photoOutput.isFastCapturePrioritizationEnabled = photoOutput.isFastCapturePrioritizationSupported
        photoOutput.isAutoDeferredPhotoDeliveryEnabled = photoOutput.isAutoDeferredPhotoDeliverySupported
        updateCapabilities(for: device)
    }
    
    private func updateCapabilities(for device: AVCaptureDevice) {
        capabilities = CaptureCapabilities(isFlashSupported: device.isFlashAvailable,
                                           isLivePhotoCaptureSupported: photoOutput.isLivePhotoCaptureSupported)
    }
}

typealias PhotoContinuation = CheckedContinuation<Photo, Error>

// MARK: - A photo capture delegate to process the captured photo.

/// An object that adopts the `AVCapturePhotoCaptureDelegate` protocol to respond to photo capture life-cycle events.
///
/// The delegate produces a stream of events that indicate its current state of processing.
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let continuation: PhotoContinuation
    private let features: EnabledPhotoFeatures
    
    private var isLivePhoto = false
    private var isProxyPhoto = false
    
    private var photoData: Data?
    private var livePhotoMovieURL: URL?
    
    /// A stream of capture activity values that indicate the current state of progress.
    let activityStream: AsyncStream<CaptureActivity>
    private let activityContinuation: AsyncStream<CaptureActivity>.Continuation
    
    /// Creates a new delegate object with the checked continuation to call when processing is complete.
    init(continuation: PhotoContinuation, features: EnabledPhotoFeatures) {
        self.continuation = continuation
        self.features = features
        
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: CaptureActivity.self)
        self.activityStream = activityStream
        self.activityContinuation = activityContinuation
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Determine if this is a live capture.
        isLivePhoto = resolvedSettings.livePhotoMovieDimensions != .zero
        activityContinuation.yield(.photoCapture(isLivePhoto: isLivePhoto))
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Signal that a capture is beginning.
        activityContinuation.yield(.photoCapture(willCapture: true, isLivePhoto: isLivePhoto))
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Indicates that Live Photo capture is over.
        activityContinuation.yield(.photoCapture(isLivePhoto: false))
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error {
            logger.debug("Error processing Live Photo companion movie: \(String(describing: error))")
        }
        livePhotoMovieURL = outputFileURL
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: Error?) {
        if let error = error {
            logger.debug("Error capturing deferred photo: \(error)")
            return
        }
        // Capture the data for this photo.
        photoData = deferredPhotoProxy?.fileDataRepresentation()
        isProxyPhoto = true
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logger.debug("Error capturing photo: \(error)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData) else {
            logger.debug("No photo data or cannot create UIImage")
            return
        }
        
        let aspectRatio = features.aspectRatio
        let croppedImage = cropImage(image, to: aspectRatio)
        
        guard let croppedPhotoData = croppedImage.jpegData(compressionQuality: 1.0) else {
            logger.debug("Cannot convert cropped UIImage to data")
            return
        }
        
        self.photoData = croppedPhotoData
    }
    
    private func cropImage(_ image: UIImage, to aspectRatio: AspectRatio) -> UIImage {
        guard let cgImageKu = image.cgImage else { return image }
        let originalAspectRatio = 0.75
        var newImageSize = image.size
        var cropZone: CGRect = .zero
        
        print("original image size: \(image.size)")
        print("original width: \(image.size.width) height: \(image.size.height)")
//        print("original scale: \(image.)")
        
        switch aspectRatio {
            
        case .ratio4_3:
            return image
        case .ratio16_9:
            if image.imageOrientation != .up {
                print("no up")
                
                print("width:\(cgImageKu.width) height:\(cgImageKu.height)")
                let h = cgImageKu.width
                let w = cgImageKu.width * 9 / 16
                newImageSize = CGSize(width: h, height: w)
            } else {
                print("up")
                newImageSize.height = CGFloat(cgImageKu.width) * 9/16
                
            }
            
            cropZone = CGRect(origin: CGPoint(x: 0, y: (cgImageKu.height - Int(newImageSize.height)) / 2), size: newImageSize)
            
            print("new image size: \(newImageSize)")
        case .ratio1_1:
            if image.imageOrientation != .up {
                newImageSize.height = image.size.height * originalAspectRatio
            } else {
                newImageSize.width = image.size.width * originalAspectRatio
            }
            
            cropZone = CGRect(origin: CGPoint(x: (cgImageKu.width - Int(newImageSize.width)) / 2, y: (cgImageKu.height - Int(newImageSize.height)) / 2), size: newImageSize)
        }
        
        guard let cgImage = cgImageKu.cropping(to: cropZone) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        defer {
            /// Finish the continuation to terminate the activity stream.
            activityContinuation.finish()
        }
        
        if let error = error {
            continuation.resume(throwing: error)
            return
        }
        
        // Ensure photoData is available
        guard let photoData else {
            continuation.resume(throwing: PhotoCaptureError.noPhotoData)
            return
        }
        
        // Perform cropping here
        guard let image = UIImage(data: photoData) else {
            continuation.resume(throwing: PhotoCaptureError.noPhotoData)
            return
        }
        
        let aspectRatio = features.aspectRatio
        let croppedImage = cropImage(image, to: aspectRatio)
        
        guard let croppedPhotoData = croppedImage.jpegData(compressionQuality: 1.0) else {
            continuation.resume(throwing: PhotoCaptureError.noPhotoData)
            return
        }
        
        // Update photoData with cropped data
        self.photoData = croppedPhotoData
        
        /// Create a photo object to save to the `MediaLibrary`.
        let photo = Photo(data: croppedPhotoData, isProxy: isProxyPhoto, livePhotoMovieURL: livePhotoMovieURL)
        // Resume the continuation by returning the captured photo.
        continuation.resume(returning: photo)
    }
}
