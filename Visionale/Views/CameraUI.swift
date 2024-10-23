/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that presents the main camera user interface.
 */

import SwiftUI
import AVFoundation

/// A view that presents the main camera user interface.
struct CameraUI<CameraModel: Camera>: PlatformView {
    
    @State var camera: CameraModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            if isRegularSize {
                regularUI
            } else {
                compactUI
            }
        }
        .overlay(alignment: .top) {
            LiveBadge()
                .opacity(camera.captureActivity.isLivePhoto ? 1.0 : 0.0)
            
        }
        .overlay {
            StatusOverlayView(status: camera.status)
        }
    }
    
    var cameraZoomFactorUI: some View {
        Text("\(camera.zoomFactor/2, specifier: "%.1f")x")
            .padding(12)
            .background(Material.regular)
            .clipShape(.circle)
            .offset(y: 24)
    }
    
    /// This view arranges UI elements vertically.
    @ViewBuilder
    var compactUI: some View {
        VStack(spacing: 0) {
            FeaturesToolbar(camera: camera)
            //            zoomSliderUI
            cameraZoomFactorUI
            Spacer()
            VStack {
                ZStack {
                    Carousel(camera: camera)
                        .padding(.bottom, padding - 50)
                    MainToolbar(camera: camera)
                        .padding(.top, padding + 200)
                }
            }
        }
    }
    
    /// This view arranges UI elements in a layered stack.
    @ViewBuilder
    var regularUI: some View {
        VStack {
            Spacer()
            ZStack {
                MainToolbar(camera: camera)
                FeaturesToolbar(camera: camera)
                    .frame(width: 250)
                    .offset(x: 250) // The vertical offset from center.
            }
            .frame(width: 740)
            .background(.ultraThinMaterial.opacity(0.8))
            .cornerRadius(12)
            .padding(.bottom, 32)
        }
    }
    
    var padding: CGFloat {
        // Dynamically calculate the offset for the bottom toolbar in iOS.
        let bounds = UIScreen.main.bounds
        let rect = AVMakeRect(aspectRatio: photoAspectRatio, insideRect: bounds)
        return (rect.minY.rounded() / 2) - 36
    }
}

