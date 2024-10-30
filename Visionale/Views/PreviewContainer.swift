/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that provides a container view around the camera preview.
 */

import SwiftUI

// Portrait-orientation aspect ratios.
//typealias AspectRatio = CGSize
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
    
    // When running in photo capture mode on a compact device size, move the preview area
    // update by the offset amount so that it's better centered between the top and bottom bars.
    private let photoModeOffset = CGFloat(-44)
    private let content: Content
    
    // State for zoom slider visibility
    @State private var showZoomSlider = false
    
    // Binding to lastZoomFactor
    @Binding var lastZoomFactor: CGFloat
    @State private var dragOffset: CGFloat = 0.0
    
    // Timer for hiding the slider after inactivity
    @State private var hideSliderWorkItem: DispatchWorkItem?
    
    @State private var hideZoomButton: Bool = false
    
    var onCarouselAction: ((Bool) -> Void)?
    
    init(camera: CameraModel, lastZoomFactor: Binding<CGFloat>, @ViewBuilder content: () -> Content, onCarouselAction: ((Bool) -> Void)? = nil) {
        self.camera = camera
        self._lastZoomFactor = lastZoomFactor
        self.content = content()
        self.onCarouselAction = onCarouselAction
    }
    
    var body: some View {
        // On compact devices, show a view finder rectangle around the video preview bounds.
        if horizontalSizeClass == .compact {
            GeometryReader{ gr in
                previewView
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if (value.translation.height <= -50) {
                                    withAnimation(.easeInOut) {
                                        camera.isFramingCarouselEnabled = true
                                    }
                                } else if (value.translation.height >= 50) {
                                    withAnimation(.easeInOut) {
                                        camera.isFramingCarouselEnabled = false
                                    }
                                }
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                handlePinchGesture(scale: value)
                            }
                            .onEnded { _ in
                                lastZoomFactor = camera.zoomFactor
                            }
                    )
                    .overlay(alignment: .bottomLeading) {
                        cameraZoomComponent
                    }
                    .overlay {
                        switch camera.activeComposition {
                        case "CENTER": CenterGrid(camera: camera).frame(width: gr.size.width, height: gr.size.width * camera.aspectRatio.size.height / camera.aspectRatio.size.width)
                        case "DIAGONAL": DiagonalGrid().frame(width: gr.size.width, height: gr.size.width * camera.aspectRatio.size.height / camera.aspectRatio.size.width)
                        case "GOLDEN RATIO": GoldenRatioGrid().frame(width: gr.size.width, height: gr.size.width * camera.aspectRatio.size.height / camera.aspectRatio.size.width)
                        case "RULE OF THIRDS": RuleOfThirdsGrid(camera: camera).frame(width: gr.size.width, height: gr.size.width * camera.aspectRatio.size.height / camera.aspectRatio.size.width)
                        case "SYMMETRIC": SymmetricGrid().frame(width: gr.size.width, height: gr.size.width * camera.aspectRatio.size.height / camera.aspectRatio.size.width)
                        default:
                            EmptyView()
                        }
                    }
                    .overlay {
                        Carousel(camera: camera)
                    }
            }
            .clipped()
            // Apply an appropriate aspect ratio based on the selected capture mode.
            .aspectRatio(camera.aspectRatio.size, contentMode: .fit)
            // In photo mode, adjust the vertical offset of the preview area to better fit the UI.
            .offset(y: photoModeOffset)
        } else {
            // On regular-sized UIs, show the content in full screen.
            previewView
        }
    }
    
    func handlePinchGesture(scale: CGFloat) {
        let delta = scale - 1.0
        let newZoomFactor = lastZoomFactor + delta * (camera.maxZoomFactor - camera.minZoomFactor)
        let clampedZoomFactor = max(camera.minZoomFactor, min(newZoomFactor, camera.maxZoomFactor))
        Task {
            await camera.setZoom(factor: clampedZoomFactor)
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
    
    @ViewBuilder
    var cameraZoomComponent: some View {
        if(!camera.isFramingCarouselEnabled) {
            HStack {
                cameraZoomButton
                if showZoomSlider {
                    zoomSlider
                }
            }
            .padding(5)
            .background(Material.ultraThin)
            .clipShape(.capsule)
            .padding(12)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: showZoomSlider)
            .opacity(hideZoomButton ? 0 : 1)
        }
    }
    @ViewBuilder
    var cameraZoomButton: some View {
        Text("\(camera.zoomFactor / 2, format: .number.precision(.fractionLength(0...1)))×")
            .font(.caption)
            .fontWeight(.medium)
            .frame(width: 30, height: 30, alignment: .center)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !showZoomSlider {
                            toggleZoomSlider()
                        }
                        adjustZoom(dragOffset: value.translation.width)
                        resetHideSliderTimer()
                    }
                    .onEnded { _ in
                        lastZoomFactor = camera.zoomFactor
                        resetHideSliderTimer()
                    }
            )
            .onTapGesture {
                toggleZoomSlider()
            }
        
    }
    
    func adjustZoom(dragOffset: CGFloat) {
        let scaleAdjustment = dragOffset / 300
        let newZoomFactor = lastZoomFactor + scaleAdjustment * (camera.maxZoomFactor - camera.minZoomFactor)
        let clampedZoomFactor = max(camera.minZoomFactor, min(newZoomFactor, camera.maxZoomFactor))
        Task {
            await camera.setZoom(factor: clampedZoomFactor)
        }
    }
    
    var zoomSlider: some View {
        Slider(value: Binding(
            get: { camera.zoomFactor },
            set: { newValue in
                Task {
                    await camera.setZoom(factor: newValue)
                }
            }
        ), in: camera.minZoomFactor...camera.maxZoomFactor)
        .onChange(of: camera.zoomFactor) {
            DispatchQueue.main.async{
                resetHideSliderTimer()
            }
        }
    }
    
    func toggleZoomSlider() {
        withAnimation {
            showZoomSlider.toggle()
        }
        if showZoomSlider {
            resetHideSliderTimer()
        } else {
            cancelHideSliderTimer()
        }
    }
    
    func resetHideSliderTimer() {
        cancelHideSliderTimer()
        let workItem = DispatchWorkItem {
            withAnimation {
                showZoomSlider = false
            }
        }
        hideSliderWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
    
    func cancelHideSliderTimer() {
        hideSliderWorkItem?.cancel()
        hideSliderWorkItem = nil
    }
}


