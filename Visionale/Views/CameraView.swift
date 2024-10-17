/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The main user interface for the sample app.
 */

import SwiftUI
import AVFoundation

@MainActor
struct CameraView: PlatformView {
    @StateObject private var camera = CameraViewModel()
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        ZStack {
            // A container view that manages the placement of the preview.
            PreviewContainer(camera: camera) {
                CameraPreview(source: camera.previewSource, device: camera.captureService.deviceLookup.cameras.first!)
                    .onTapGesture { location in
                        // Focus and expose at the tapped point.
                        Task { await camera.focusAndExpose(at: location) }
                    }
                /// The value of `shouldFlashScreen` changes briefly to `true` when capture
                /// starts, then immediately changes to `false`. Use this to
                /// flash the screen to provide visual feedback.
                    .opacity (camera.shouldFlashScreen ? 0 : 1)
            }
            // The main camera user interface.
            CameraUI(camera: camera)
        }
        .task {
            // Start the capture pipeline.
            await camera.start()
        }
    }
}
