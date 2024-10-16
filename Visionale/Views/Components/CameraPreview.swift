/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that presents a video preview of the captured content.
 */

import SwiftUI
@preconcurrency import AVFoundation

struct CameraPreview: UIViewRepresentable {
    private let source: PreviewSource
    private let device: AVCaptureDevice
    init(source: PreviewSource, device: AVCaptureDevice) {
        self.source = source
        self.device = device
    }
    func makeUIView(context: Context) -> PreviewView {
        let preview = PreviewView(device: self.device)
        // Connect the preview layer to the capture session.
        source.connect(to: preview)
        return preview
    }
    
    func updateUIView(_ previewView: PreviewView, context: Context) {
        // No-op.
    }
    
    /// A class that presents the captured content.
    ///
    /// This class owns the `AVCaptureVideoPreviewLayer` that presents the captured content.
    ///
    class PreviewView: UIView, PreviewTarget {
        private var lastZoomFactor: CGFloat = 2.0
        private var zoomFactor: ClosedRange<CGFloat> = 1.0...1.0
        // Current video active input
        private var device: AVCaptureDevice
        init(device: AVCaptureDevice) {
            self.device = device
            super.init(frame: .zero)
#if targetEnvironment(simulator)
            // The capture APIs require running on a real device. If running
            // in Simulator, display a static image to represent the video feed.
            let imageView = UIImageView(frame: UIScreen.main.bounds)
            imageView.image = UIImage(named: "video_mode")
            imageView.contentMode = .scaleAspectFill
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(imageView)
#endif
            setupPinchGesture()
            setupVideoMinMaxZoomFactor()
            setInitialZoomFactor()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // Use the preview layer as the view's backing layer.
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
        
        nonisolated func setSession(_ session: AVCaptureSession) {
            // Connects the session with the preview layer, which allows the layer
            // to provide a live view of the captured content.
            Task { @MainActor in
                previewLayer.session = session
            }
        }
        // MARK: - Pinch Gesture Handling for Zoom
        /// Function that returns the videoMaxZoomfactor
        private func setupVideoMinMaxZoomFactor() {
            guard let availableZoomFactors = device.activeFormat.systemRecommendedVideoZoomRange else { return }
            self.zoomFactor = availableZoomFactors
            print(device.virtualDeviceSwitchOverVideoZoomFactors)
            print(device.localizedName)
        }
        
        /// Function to set initial zoom factor to 2
        private func setInitialZoomFactor() {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = lastZoomFactor
                print("woi jancok")
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        private func setupPinchGesture() {
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            self.addGestureRecognizer(pinchGesture)
        }
        
        @objc private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
            // Return zoom value between the minimum and maximum zoom values
            func minMaxZoom(_ factor: CGFloat) -> CGFloat {
                return min(min(max(factor, zoomFactor.lowerBound), zoomFactor.upperBound), device.activeFormat.videoMaxZoomFactor)
            }
            
            func update(scale factor: CGFloat) {
                do {
                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }
                    device.videoZoomFactor = factor
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            
            let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
            
            switch pinch.state {
            case .began, .changed:
                update(scale: newScaleFactor)
            case .ended:
                lastZoomFactor = minMaxZoom(newScaleFactor)
                update(scale: lastZoomFactor)
            default:
                break
            }
        }
    }
}

/// A protocol that enables a preview source to connect to a preview target.
///
/// The app provides an instance of this type to the client tier so it can connect
/// the capture session to the `PreviewView` view. It uses these protocols
/// to prevent explicitly exposing the capture objects to the UI layer.
///
protocol PreviewSource: Sendable {
    // Connects a preview destination to this source.
    func connect(to target: PreviewTarget)
}

/// A protocol that passes the app's capture session to the `CameraPreview` view.
protocol PreviewTarget {
    // Sets the capture session on the destination.
    func setSession(_ session: AVCaptureSession)
}

/// The app's default `PreviewSource` implementation.
struct DefaultPreviewSource: PreviewSource {
    
    private let session: AVCaptureSession
    
    init(session: AVCaptureSession) {
        self.session = session
    }
    
    func connect(to target: PreviewTarget) {
        target.setSession(session)
    }
}
