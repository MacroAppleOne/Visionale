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
    @State var isSettingSheetPresented: Bool = false
    
    var body: some View {
        @Bindable var features = camera.photoFeatures
        
        HStack(spacing: 30) {
            if isCompactSize {
                torchButton
                livePhotoButton
                Spacer()
                gridOverlayButton
            } else {
                Spacer()
                torchButton
                livePhotoButton
            }
        }
        .buttonStyle(DefaultButtonStyle(size: isRegularSize ? .large : .small))
        .padding([.leading, .trailing])
        .sheet(isPresented: $isSettingSheetPresented, content: {
            NavigationStack{
                Text("GG Lah")
            }.navigationTitle("Settings")
        })
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
            camera.toggleTorch()
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
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }
    
    // A button to toggle the information sheet
    var gridOverlayButton: some View {
        Button {
            camera.toggleGridOverlay()
        } label: {
            VStack{
                Image(systemName: camera.isGridOverlayVisible ? "viewfinder.circle.fill" : "viewfinder.circle")
                    .symbolRenderingMode(camera.isGridOverlayVisible ? .monochrome : .hierarchical  )
                    .fontWeight(.thin)
                    .font(.title2)
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer)))
                    .foregroundColor(camera.isGridOverlayVisible ? .accentColor: .primary)
            }
        }
        .frame(width: smallButtonSize.width, height: smallButtonSize.height)
    }
    
    // A button to open Setting page
    var settingButton: some View {
        Button{
            isSettingSheetPresented.toggle()
        } label: {
            Image(systemName: "gear.circle")
            //                .foregroundColor(isSettingSheetPresented ? .accentColor : .primary)
                .foregroundStyle(isSettingSheetPresented ? .accent: .primary)
        }
    }
    
    @ViewBuilder
    var compactSpacer: some View {
        if !isRegularSize {
            Spacer()
        }
    }
}
