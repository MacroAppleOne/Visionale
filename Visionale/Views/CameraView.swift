/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The main user interface for the sample app.
 */

import SwiftUI
import UIKit
import AVFoundation
import CoreGraphics

//struct LineSegment: Shape {
//    func path(in rect: CGRect) -> Path {
//
//    }
//}

@MainActor
struct CameraView<CameraModel: Camera>: PlatformView {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var camera: CameraModel
    @State var bestShotPoint: CGPoint = .zero
    @State var boundingBox: CGRect = .zero
    @State var cp: [StraightLine] = []
    @State var contour: CGPath? = .init(rect: .zero, transform: .none)
    @State var contourRect: [CGRect] = []
    @State private var lastZoomFactor: CGFloat = 1.0
    @State private var progress: CGFloat = 0.0
    
    @State private var isAnimating = false
    @State private var showOverlay = true
    @State private var shakeCount = 0
    
//    @State var motionManager: MotionManager
    
    private var cameraOffset: CGFloat {
        if camera.aspectRatio == .ratio16_9 {
            return 0
        } else if (camera.aspectRatio == .ratio1_1){
            return -72
        } else {
            return -12
        }
    }
    
    @ViewBuilder
    var SwitchCompositionButton: some View {
        if showOverlay, camera.activeComposition.lowercased() != camera.mlcLayer?.predictionLabel?.replacingOccurrences(of: "_", with: " ") && camera.mlcLayer?.predictionLabel != "" {
            Button {
                camera.updateActiveComposition((camera.mlcLayer?.predictionLabel!.uppercased().replacingOccurrences(of: "_", with: " "))!)
            } label: {
                Text("Switch to \(camera.mlcLayer?.predictionLabel ?? "Unknown")".uppercased().replacingOccurrences(of: "_", with: " "))
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                // A container view that manages the placement of the preview.
                PreviewContainer(camera: camera, lastZoomFactor: $lastZoomFactor) {
                    GeometryReader { gr in
                        CameraPreview(source: camera.previewSource, camera: camera)
                            .overlay(alignment: .topLeading) {
                                //                            ForEach(cp, id: \.id) { lines in
                                //                                // For each array of StraightLine within cp
                                //                                Path { path in
                                //                                    path.move(to: lines.start)
                                //                                    path.addLine(to: lines.end)
                                //                                }
                                //                                .transform(CGAffineTransform(scaleX: gr.size.width, y: gr.size.height))
                                //                                .stroke(Color.red, lineWidth: 1)
                                //                                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                                //                            }
                                //                        }
                                //                        .overlay(alignment: .topLeading) {
                                //                            let transform = CGAffineTransform(scaleX: gr.size.width, y: gr.size.height)
                                // 
                                //                            let adjustedX = boundingBox.origin.x
                                //                            let adjustedY = (1 - boundingBox.origin.y - boundingBox.height)
                                //                            let adjustedWidth = boundingBox.width
                                //                            let adjustedHeight = boundingBox.height
                                //
                                //                            Path { path in
                                //                                path.addRect(CGRect(x: adjustedX, y: adjustedY, width: adjustedWidth, height: adjustedHeight), transform: transform)
                                //                            }
                                //                            .stroke(Color.blue, lineWidth: 1)
                                                        }
                                .onTapGesture { location in
                                    // Focus and expose at the tapped point.
                                    Task { await camera.focusAndExpose(at: location) }
                                }
                                .onTapGesture(count: 3) {
                                    camera.mlcLayer?.guidanceSystem?.reset()
                                }
                                /// The value of `shouldFlashScreen` changes briefly to `true` when capture
                                /// starts, then immediately changes to `false`. Use this to
                                /// flash the screen to provide visual feedback.
                                .opacity(camera.shouldFlashScreen ? 0 : 1)
                                .overlay(alignment: .topLeading) {
                                    if (bestShotPoint != .zero) {
                                        ZStack {
                                            Circle()
                                                .foregroundStyle(Color.accent).opacity(0.75)
                                                .frame(width: 0.1 * gr.size.width, height: 0.1 * gr.size.width)
                                                .position(
                                                    x: bestShotPoint.x * gr.size.width - 0.05,
                                                    y: bestShotPoint.y * gr.size.height - 0.05
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
                                .overlay(alignment: .top) {
                                    LiveBadge()
                                        .opacity(camera.captureActivity.isLivePhoto ? 1.0 : 0.0)
                                }
                                .overlay {
                                    StatusOverlayView(status: camera.status)
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
                    .offset(y: cameraOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    //                .padding(.top)
                    //                .if(camera.aspectRatio == .ratio16_9){ view in
                    //                    view.padding(.top)
                    //                }
                }
                .padding(.top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top){
                    VStack{
                        FeaturesToolbar(camera: camera)
                        SwitchCompositionButton
                    }
                }
                .overlay(alignment: .bottom){
                    VStack{
                        if !camera.isZoomSliderEnabled || camera.aspectRatio == .ratio1_1 {
                            Carousel(camera: camera, geometry: geometry)
                                .padding(.bottom, 12)
                            
                        }
                        MainToolbar(camera: camera)
                    }
                    .padding(.bottom, geometry.size.height / 20)
                }
                .animation(.linear(duration: 0.1), value: camera.aspectRatio)
                .background(
                    ShakeDetector(onShake: {
                        camera.mlcLayer?.guidanceSystem?.reset()
                    })
                )
            }
        }
        
        //    func startTimer() {
        //        // Start animating the background fill over 5 seconds
        //        isAnimating = true
        //        showOverlay = true
        //        withAnimation(.linear(duration: 5)) {
        //            progress = 1.0
        //        }
        //
        //        // Reset after 5 seconds
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //            progress = 0.0
        //            isAnimating = false
        //            withAnimation(.easeOut(duration: 1)) { // Fade out animation
        //                showOverlay = false // Hide overlay after 5 seconds
        //            }
        //        }
        //    }
    }

class ShakeDetectionController: UIViewController {
    var onShake: (() -> Void)?
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            logger.debug("shake detected")
            onShake?()
        }
    }
}

struct ShakeDetector: UIViewControllerRepresentable {
    var onShake: () -> Void
    
    func makeUIViewController(context: Context) -> ShakeDetectionController {
        let controller = ShakeDetectionController()
        controller.onShake = onShake
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ShakeDetectionController, context: Context) {
        uiViewController.onShake = onShake
    }
}

#Preview {
    CameraView(camera: PreviewCameraModel())
}
