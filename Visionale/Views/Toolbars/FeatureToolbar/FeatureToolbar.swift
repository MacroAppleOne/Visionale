/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that presents controls to enable capture features.
 */

import SwiftUI

/// A view that presents controls to enable capture features.
struct FeaturesToolbar<CameraModel: Camera>: PlatformView {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var camera: CameraModel
    
    var body: some View {
        @Bindable var features = camera.photoFeatures
        ZStack{
            HStack(spacing: 30) {
                if isCompactSize {
                    torchButton
                    livePhotoButton
                    Spacer()
                    otherIcontoggle
                } else {
                    Spacer()
                    livePhotoButton
                    torchButton
                }
            }
            HStack{
                Spacer()
                carouselToggleButton
                Spacer()
            }
        }
        .buttonStyle(DefaultButtonStyle(size: isRegularSize ? .large : .small))
        .padding([.leading, .trailing])
    }
    
    var carouselToggleButton: some View {
        Button{
            camera.toggleFramingCarousel()
        } label: {
            Image(systemName: camera.isFramingCarouselEnabled ?  "chevron.down.circle.fill" :  "chevron.up.circle.fill")
                .font(.title2)
                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                .foregroundStyle(camera.isFramingCarouselEnabled ? .accent:.primary , .secondary, .tertiary)
        }
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }
    
//    var imageClassification: some View {
//        Text(camera.mlcLayer?.predictionLabel ?? "Unknown")
//            .padding(12)
//            .background(.base)
//            .clipShape(.buttonBorder)
//    }
    
    var otherIcontoggle: some View {
        Button {
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
                .fontWeight(.thin)
            
        }
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }
    
    //  A button to toggle the enabled state of Live Photo capture.
    var livePhotoButton: some View {
        Button {
            camera.photoFeatures.isLivePhotoEnabled.toggle()
        } label: {
            VStack {
                Image(systemName: "livephoto")
                    .foregroundColor(camera.photoFeatures.isLivePhotoEnabled ? .accentColor : .primary)
            }
        }
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }
    
    
    // A button to toggle the torch in the device
    var torchButton: some View {
        Button {
            Task{
                await camera.toggleTorch()
            }
        } label: {
            VStack{
                Image(systemName: camera.isTorchOn ? "bolt.circle.fill" : "bolt.slash.circle")
                    .symbolRenderingMode(camera.isTorchOn ? .monochrome : .hierarchical)
                    .fontWeight(.thin)
                    .font(.title2)
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                    .foregroundColor(camera.isTorchOn ? .accentColor: .primary)
            }
        }
    }
    
    @ViewBuilder
    var compactSpacer: some View {
        if !isRegularSize {
            Spacer()
        }
    }
}
