/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The main user interface for the sample app.
 */

import SwiftUI
import AVFoundation

@MainActor
struct CameraView: PlatformView {
    @StateObject private var camera: CameraViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var viewModel: CompositionViewModel
    @State var activeComposition: String? = ""
    @State private var goldenRatioFlipped = false
    @State private var triangleFlipped = false
    @State private var dragOffset: CGSize = .zero
    let photoModeOffset: CGFloat = -44
    
    init() {
        let cameraViewModel = CameraViewModel() // Initialize camera first
        _camera = StateObject(wrappedValue: cameraViewModel) // Assign camera
        _viewModel = StateObject(wrappedValue: CompositionViewModel(ml: cameraViewModel.captureService.mlcLayer)) // Initialize viewModel with camera's mlcLayer
    }
    
    var body: some View {
        ZStack {
            // A container view that manages the placement of the preview.
            CameraPreviewContainer(camera: camera, compositionVM: viewModel) {
                GeometryReader { gr in
                    CameraPreview(source: camera.previewSource, device: camera.captureService.deviceLookup.cameras.first!)
                        .onTapGesture { location in
                            // Focus and expose at the tapped point.
                            Task { await camera.focusAndExpose(at: location) }
                        }
                    /// The value of `shouldFlashScreen` changes briefly to `true` when capture
                    /// starts, then immediately changes to `false`. Use this to
                    /// flash the screen to provide visual feedback.
                        .opacity (camera.shouldFlashScreen ? 0 : 1)
                        .overlay {
                            let gridWidth = gr.size.width
                            let gridHeight = gr.size.width * 4 / 3
                            let goldenRatioWidth = gridHeight * 0.605
                            
                            switch activeComposition {
                            case "CENTER": CenterGrid().frame(width: gridWidth, height: gridHeight)
                            case "DIAGONAL": DiagonalGrid().frame(width: gridWidth, height: gridHeight)
                            case "GOLDEN RATIO": GoldenRatioGrid()
                                    .frame(width: goldenRatioWidth, height: gridHeight)
                                    .rotation3DEffect(
                                        .degrees(goldenRatioFlipped ? 180 : 0),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                            case "RULE OF THIRDS": RuleOfThirdsGrid().frame(width: gridWidth, height: gridHeight)
                            case "SYMMETRIC": SymmetricGrid().frame(width: gridWidth, height: gridHeight)
                            case "TRIANGLE": TriangleGrid().frame(width: gridWidth, height: gridHeight)
                            case .none:
                                EmptyView()
                            case .some(_):
                                EmptyView()
                            }
                        }
                        .onChange(of: viewModel.activeComposition) {
                            self.activeComposition = viewModel.activeComposition
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    dragOffset = gesture.translation
                                }
                                .onEnded { _ in
                                    print("ended")
                                    print(dragOffset.width)
                                    if dragOffset.width > 20 || (dragOffset.width < 0 && dragOffset.width < -100) {
                                        print("should be flipped")
                                        goldenRatioFlipped = true
                                    }
                                    dragOffset = .zero
                                }
                        )
                }
            }
            // The main camera user interface.
            CameraUI(camera: camera, compositionVM: viewModel)
        }
        .task {
            // Start the capture pipeline.
//            print(self.viewModel.compositions)
            await camera.start()
        }
    }
}
