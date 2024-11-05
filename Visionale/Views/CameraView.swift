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
    
    @State private var progress: CGFloat = 0.0
    @State private var isAnimating = false
    
    @State private var showOverlay = true
    
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
                    //                        .overlay(alignment: .topLeading) {
                    //                            let transform = CGAffineTransform(scaleX: gr.size.width, y: gr.size.height)
                    //                            let adjustedX = boundingBox.origin.x
                    //                            let adjustedY = (1 - boundingBox.origin.y - boundingBox.height)
                    //                            let adjustedWidth = boundingBox.width
                    //                            let adjustedHeight = boundingBox.height
                    //                            
                    //                            let rect = CGRect(x: adjustedX, y: adjustedY, width: adjustedWidth, height: adjustedHeight)
                    //                            
                    //                            Path { path in
                    //                                path.addRect(rect, transform: transform)
                    //                            }
                    //                            .stroke(Color.red, lineWidth: 1)
                    //                        }
                        .overlay(alignment: .top) {
                            if showOverlay, camera.activeComposition.lowercased() != camera.mlcLayer?.predictionLabel?.replacingOccurrences(of: "_", with: " ") && camera.mlcLayer?.predictionLabel != "" {
                                Button {
                                    let recommendedComposition = camera.compositions.first(where: {$0.name.lowercased() == camera.mlcLayer?.predictionLabel?.lowercased().replacingOccurrences(of: "_", with: " ")})
                                    camera.updateActiveComposition(recommendedComposition?.name ?? "")
                                } label: {
                                    Text("Switch to \(camera.mlcLayer?.predictionLabel ?? "Unknown")".uppercased())
                                        .font(.subheadline)
                                        .foregroundStyle(.circle)
                                        .fontWeight(.semibold)
                                        .padding(10)
                                        .background(
                                            ZStack(alignment: .leading) {
                                                Color.lightBase // Initial color background
                                                Color.base
                                                    .frame(width: 300 * progress) // Width grows with progress
                                                    .cornerRadius(4)
                                            }
                                        )
                                        .cornerRadius(12)
                                        .offset(x: 0, y: 10)
                                }
                                
                                .frame(width: 300)
                                .opacity(showOverlay ? 1 : 0) // Fade out effect
                                .animation(.easeOut(duration: 1), value: showOverlay)
                            }
                        }
                        .onChange(of: camera.mlcLayer?.predictionLabel){
                                startTimer()
                        }
                        .overlay(alignment: .topLeading) {
                            if (bestShotPoint != .zero) {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(Color.accent).opacity(0.75)
                                        .frame(width: 0.1 * gr.size.width, height: 0.1 * gr.size.width)
                                        .position(
                                            x: bestShotPoint.x * gr.size.width,
                                            y: bestShotPoint.y * gr.size.height
                                        )
                                    
                                    Text("Point here")
                                        .position(
                                            x: bestShotPoint.x * gr.size.width,
                                            y: bestShotPoint.y * gr.size.height + 0.075 * gr.size.width
                                        )
                                        .font(.caption)
                                }
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
    
    func startTimer() {
        // Start animating the background fill over 5 seconds
        isAnimating = true
        showOverlay = true
        withAnimation(.linear(duration: 5)) {
            progress = 1.0
        }
        
        // Reset after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            progress = 0.0
            isAnimating = false
            withAnimation(.easeOut(duration: 1)) { // Fade out animation
                        showOverlay = false // Hide overlay after 5 seconds
                    }
        }
    }
}
