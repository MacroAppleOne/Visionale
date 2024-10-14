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
//    @State var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State var bestShotPoint: CGPoint = .zero
    
    var body: some View {
        ZStack {
            // A container view that manages the placement of the preview.
            PreviewContainer(camera: camera) {
                GeometryReader { gr in
                    CameraPreview(source: camera.previewSource)
                        .onTapGesture { location in
                            // Focus and expose at the tapped point.
                            Task { await camera.focusAndExpose(at: location) }
                        }
                        .overlay(alignment: .top){
                            ClassifiedLabelCard(camera: camera)
                                .offset(y: 100)
                        }
                        .overlay(alignment: .topLeading) {
                            Circle()
                                .offset(
                                    x: bestShotPoint.x * gr.size.width,
                                    y: bestShotPoint.y * gr.size.height
                                )
                                .foregroundStyle(.yellow)
                                .frame(width: 50, height: 50)
                            //                            Rectangle()
                            //                                .foregroundStyle(.clear)
                            //                                .border(Color.red, width: 1)
                            //                                .frame(width: boxWidth * gr.size.height, height: boxHeight * gr.size.width)
                            //                                .offset(x: originX * gr.size.width, y: originY * gr.size.height)
                            //                                .offset(x: originX * gr.size.width , y: originY * gr.size.height + ((gr.size.height - (gr.size.width * 4 / 3)) / 2))
                        }
                    /// The value of `shouldFlashScreen` changes briefly to `true` when capture
                    /// starts, then immediately changes to `false`. Use this to
                    /// flash the screen to provide visual feedback.
                        .onChange(of: camera.captureService.mlcLayer.boundingBox) {
                            Task {
                                bestShotPoint = camera.captureService.mlcLayer.bestShotPoint ?? .zero
                            }
                        }
//                        .onAppear {
//                            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
//                            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
//                                self.orientation = UIDevice.current.orientation
//                            }
//                        }
//                        .onDisappear {
//                            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
//                            UIDevice.current.endGeneratingDeviceOrientationNotifications()
//                        }
                }
                
            }
            // The main camera user interface.
            CameraUI(camera: $camera)
        }
    }
}

#Preview {
    //    CameraView(camera: PreviewCameraModel(cameraView))
}
