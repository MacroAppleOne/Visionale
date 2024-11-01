/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The main user interface for the sample app.
 */

import SwiftUI
import AVFoundation

@MainActor
struct CameraView<CameraModel: Camera>: PlatformView {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var camera: CameraModel
    @State var bestShotPoint: CGPoint = .zero
    @State var boundingBox: CGRect = .zero
    @State private var lastZoomFactor: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // A container view that manages the placement of the preview.
            PreviewContainer(camera: camera, lastZoomFactor: $lastZoomFactor) {
                GeometryReader { gr in
                    CameraPreview(source: camera.previewSource)
                        .onTapGesture { location in
                            // Focus and expose at the tapped point.
                            Task { await camera.focusAndExpose(at: location) }
                        }
                    /// The value of `shouldFlashScreen` changes briefly to `true` when capture
                    /// starts, then immediately changes to `false`. Use this to
                    /// flash the screen to provide visual feedback.
                        .opacity(camera.shouldFlashScreen ? 0 : 1)
                    // INI JANGAN DIHAPUS DULU YA BANG
                        .overlay(alignment: .topLeading) {
                            let transform = CGAffineTransform(scaleX: gr.size.width, y: gr.size.height)
                            let adjustedX = boundingBox.origin.x
                            let adjustedY = (1 - boundingBox.origin.y - boundingBox.height)
                            let adjustedWidth = boundingBox.width
                            let adjustedHeight = boundingBox.height
                            
                            let rect = CGRect(x: adjustedX, y: adjustedY, width: adjustedWidth, height: adjustedHeight)
                            
                            Path { path in
                                path.addRect(rect, transform: transform)
                            }
                            .stroke(Color.red, lineWidth: 1)
                        }
                        .overlay(alignment: .topLeading) {
//                            Circle()
//                                .foregroundStyle(.red.opacity(0.5))
//                                .frame(width: 0.1 * gr.size.width, height: 0.1 * gr.size.height)
//                                .position(x: (0.107 + 0.236) * gr.size.width, y: gr.size.height - (0.282 * gr.size.height))
                            if (bestShotPoint != .zero) {
                                Circle()
                                    .foregroundStyle(Color.accent).opacity(0.5)
                                    .frame(width: 0.1 * gr.size.width, height: 0.1 * gr.size.width)
                                    .position(
                                        x: bestShotPoint.x * gr.size.width,
                                        y: bestShotPoint.y * gr.size.height
                                    )
                            }
                        }
                        .onChange(of: camera.mlcLayer?.guidanceSystem?.bestShotPoint ?? .zero) {
                            Task {
                                withAnimation {
                                    bestShotPoint = camera.mlcLayer?.guidanceSystem?.bestShotPoint ?? .zero
                                    boundingBox = camera.mlcLayer?.guidanceSystem?.trackedObjects?.first ?? .zero
                                }
                            }
                        }
                        .onChange(of: camera.mlcLayer?.guidanceSystem?.isAligned) { _, isAligned in
                            if (isAligned == true ) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                }
            }
            // The main camera user interface.
            CameraUI<CameraModel>(camera: camera)
        }
    }
}
