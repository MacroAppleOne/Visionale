//
//  CameraPreviewContainer.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 18/10/24.
//


import SwiftUI

// Portrait-orientation aspect ratios.
typealias AspectRatio = CGSize
let currentAspectRatio = AspectRatio(width: 9.0, height: 16.0)

/// A view that provides a container view around the camera preview.
///
/// This view applies transition effects when changing capture modes or switching devices.
/// On a compact device size, the app also uses this view to offset the vertical position
/// of the camera preview to better fit the UI when in photo capture mode.
@MainActor
struct CameraPreviewContainer<Content: View, CameraModel: Camera>: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var camera: CameraModel
    
    // State values for transition effects.
    @State private var blurRadius = CGFloat.zero
    
    @State var compositionVM: CompositionViewModel
    @State var activeComposition: String? = nil
    
    // When running in photo capture mode on a compact device size, move the preview area
    // update by the offset amount so that it's better centered between the top and bottom bars.
    private let photoModeOffset = CGFloat(-44)
    private let content: Content
    
    init(camera: CameraModel, compositionVM: CompositionViewModel, @ViewBuilder content: () -> Content) {
        self.camera = camera
        self.content = content()
        self.compositionVM = compositionVM
    }
    
    var body: some View {
        // On compact devices, show a view finder rectangle around the video preview bounds.
        if horizontalSizeClass == .compact {
            GeometryReader { gr in
                ZStack {
                    previewView
                }
                .clipped()
                // Apply an appropriate aspect ratio based on the selected capture mode.
                .aspectRatio(currentAspectRatio, contentMode: .fit)
                // In photo mode, adjust the vertical offset of the preview area to better fit the UI.
                .offset(y: photoModeOffset)
                .overlay {
                    switch activeComposition {
                    case "CENTER": CenterGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3).offset(y: photoModeOffset)
                    case "DIAGONAL": DiagonalGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3).offset(y: photoModeOffset)
                    case "GOLDEN RATIO": GoldenRatioGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3).offset(y: photoModeOffset)
                    case "RULE OF THIRDS": RuleOfThirdsGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3).offset(y: photoModeOffset)
                    case "SYMMETRIC": SymmetricGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3).offset(y: photoModeOffset)
                    case "TRIANGLE": TriangleGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3).offset(y: photoModeOffset)
                    case .none:
                        EmptyView()
                    case .some(_):
                        EmptyView()
                    }
                }
                .onChange(of: compositionVM.activeComposition) {
                    self.activeComposition = compositionVM.activeComposition
                }
            }
            .task {
//                print(self.compositionVM.compositions)
            }
        }
        else {
            // On regular-sized UIs, show the content in full screen.
            previewView
        }
        
    }
    
    /// Attach animations to the camera preview.
    var previewView: some View {
        content
            .blur(radius: blurRadius, opaque: true)
            .onChange(of: camera.isSwitchingModes, updateBlurRadius(_:_:))
            .onChange(of: camera.isSwitchingVideoDevices, updateBlurRadius(_:_:))
    }
    
    func updateBlurRadius(_: Bool, _ isSwitching: Bool) {
        withAnimation {
            blurRadius = isSwitching ? 30 : 0
        }
    }
}
