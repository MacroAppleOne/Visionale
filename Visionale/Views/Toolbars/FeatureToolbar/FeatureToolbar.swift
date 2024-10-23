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
        
        HStack(spacing: 30) {
            if isCompactSize {
                livePhotoButton
                torchButton
                Spacer()
                cameraZoomFactorUI
                imageClassification
            } else {
                Spacer()
                livePhotoButton
                torchButton
                
            }
        }
        .buttonStyle(DefaultButtonStyle(size: isRegularSize ? .large : .small))
        .padding([.leading, .trailing])
    }
    
    var cameraZoomFactorUI: some View {
        Text("\(camera.zoomFactor/2, specifier: "%.1f")x")
            .padding(12)
            .background(Material.regular)
            .clipShape(.buttonBorder)
    }
    
    var imageClassification: some View {
        Text(camera.mlcLayer?.predictionLabels ?? "Unknown")
            .padding(12)
            .background(.base)
            .clipShape(.buttonBorder)
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
