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
        ZStack{
            HStack(spacing: 30) {
                if isCompactSize {
                    torchButton
                    livePhotoButton
                    Spacer()
                    aspectRatioButton
//                    otherIcontoggle
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
        .backgroundStyle(.darkGradient)
    }
    
    var carouselToggleButton: some View {
        Button{
            withAnimation(.default){
                camera.isFramingCarouselEnabled.toggle()
            }
        } label: {
            Image(systemName: camera.isFramingCarouselEnabled ?  "chevron.down.circle.fill" :  "chevron.up.circle.fill")
                .font(.title2)
                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                .foregroundStyle(camera.isFramingCarouselEnabled ? .accent:.primary , .secondary, .tertiary)
        }
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }
    
    
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
            Image(systemName: "livephoto")
                .foregroundColor(camera.photoFeatures.isLivePhotoEnabled ? .accentColor : .primary)
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
            Image(systemName: camera.isTorchOn ? "bolt.circle.fill" : "bolt.slash.circle")
                .symbolRenderingMode(camera.isTorchOn ? .monochrome : .hierarchical)
                .fontWeight(.thin)
                .font(.title2)
                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                .foregroundColor(camera.isTorchOn ? .accentColor: .primary)
        }
    }
    
    // A button to toggle aspect-ratio changer
//    var aspectRatioButton: some View {
//        //        Button {
//        //            Task {
//        //                // Add your button action here
//        //            }
//        //        } label: {
//        //            Image(systemName: "custom.aspectratio.circle")
//        //        }
//        ////        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
//        //
//        //
//        Menu("\(camera.aspectRatio)") {
//            ForEach(listOfAspectRatios, id: \.self) { item in
//                Button("\(item)", action: {
//                    camera.aspectRatio = item
//                })
//            }
//        }
//    }
    
    var aspectRatioButton: some View {
        Button {
            camera.toggleAspectRatio()
        } label: {
            ZStack {
//                Image("custom.aspectratio.circle")
//                    .symbolRenderingMode(.hierarchical)
//                    .fontWeight(.thin)
                // Overlay the aspect ratio text
                Text(camera.aspectRatio.description)
                    .font(.footnote)
                    .foregroundColor(.primary)
//                    .offset(y: 12) // Adjust position as needed
            }
        }
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }

    
    @ViewBuilder
    var compactSpacer: some View {
        if !isRegularSize {
            Spacer()
        }
    }
}
