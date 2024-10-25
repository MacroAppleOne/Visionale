/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that provides a container view around the camera preview.
 */

import SwiftUI

// Portrait-orientation aspect ratios.
typealias AspectRatio = CGSize
/// A view that provides a container view around the camera preview.
///
/// This view applies transition effects when changing capture modes or switching devices.
/// On a compact device size, the app also uses this view to offset the vertical position
/// of the camera preview to better fit the UI when in photo capture mode.
@MainActor
struct PreviewContainer<Content: View, CameraModel: Camera>: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var camera: CameraModel
    
    // State values for transition effects.
    @State private var blurRadius = CGFloat.zero
    
    // New State Variables for Zoom Control
    @State private var showZoomSlider: Bool = false
    @State private var hideSliderWorkItem: DispatchWorkItem?
    
    // When running in photo capture mode on a compact device size, move the preview area
    // update by the offset amount so that it's better centered between the top and bottom bars.
    private let photoModeOffset = CGFloat(-44)
    private let content: Content
    
    init(camera: CameraModel, @ViewBuilder content: () -> Content) {
        self.camera = camera
        self.content = content()
    }
    
    var body: some View {
        // On compact devices, show a view finder rectangle around the video preview bounds.
        if horizontalSizeClass == .compact {
            GeometryReader{ gr in
                previewView
                    .overlay(alignment: .bottomLeading) {
                        ZStack(alignment: .bottomLeading) {
                            if showZoomSlider {
                                zoomSlider
                                    .transition(.move(edge: .trailing))
                            } else {
                                cameraZoomButton
                                    .transition(.move(edge: .leading))
                            }
                        }
                        .animation(.default, value: showZoomSlider)
                    }
                
                    .overlay {
                        switch camera.activeComposition {
                        case "CENTER": CenterGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3)
                        case "DIAGONAL": DiagonalGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3)
                        case "GOLDEN RATIO": GoldenRatioGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3)
                        case "RULE OF THIRDS": RuleOfThirdsGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3)
                        case "SYMMETRIC": SymmetricGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3)
                        case "TRIANGLE": TriangleGrid().frame(width: gr.size.width, height: gr.size.width * 4 / 3)
                        default:
                            EmptyView()
                        }
                    }
            }
            .clipped()
            // Apply an appropriate aspect ratio based on the selected capture mode.
            .aspectRatio(camera.aspectRatio, contentMode: .fit)
            // In photo mode, adjust the vertical offset of the preview area to better fit the UI.
            .offset(y: photoModeOffset)
        } else {
            // On regular-sized UIs, show the content in full screen.
            previewView
        }
    }
    
    /// Attach animations to the camera preview.
    var previewView: some View {
        content
            .blur(radius: blurRadius, opaque: true)
            .onChange(of: camera.isSwitchingVideoDevices, updateBlurRadius(_:_:))
    }
    
    func updateBlurRadius(_: Bool, _ isSwitching: Bool) {
        withAnimation {
            blurRadius = isSwitching ? 30 : 0
        }
    }
    
    //    var cameraZoomButton: some View {
    //        Text("\(camera.zoomFactor / 2, format: .number.precision(.fractionLength(0...1)))x")
    //            .font(.caption)
    //            .padding()
    //            .background(Material.thin)
    //            .clipShape(Circle())
    //            .padding(8)
    //    }
    
    var cameraZoomButton: some View {
        Text("\(camera.zoomFactor / 2, format: .number.precision(.fractionLength(0...1)))x")
            .font(.caption)
            .padding()
            .background(Material.thin)
            .clipShape(Circle())
            .padding(8)
            .onTapGesture {
                withAnimation {
                    showZoomSlider = true
                }
                scheduleHideSlider()
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        withAnimation {
                            showZoomSlider = true
                        }
                        scheduleHideSlider()
                    }
            )
    }
    
    var zoomSlider: some View {
        GeometryReader { geometry in
            Slider(value: Binding(
                get: { camera.zoomFactor },
                set: { newValue in
                    Task { await camera.setZoomFactor(newValue) }
                    scheduleHideSlider()
                }
            ), in: camera.minZoomFactor...camera.maxZoomFactor)
            .padding()
            .background(Material.thin)
            .frame(width: geometry.size.width)
        }
    }
    
    func scheduleHideSlider() {
        hideSliderWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation {
                showZoomSlider = false
            }
        }
        hideSliderWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}


