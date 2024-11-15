/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A view that displays controls to capture, switch cameras, and view the last captured media item.
 */

import SwiftUI
import PhotosUI

/// A view that displays controls to capture, switch cameras, and view the last captured media item.
struct MainToolbar<CameraModel: Camera>: PlatformView {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var camera: CameraModel
    
    var body: some View {
        HStack {
            ThumbnailButton(camera: camera)
//                .border(.primary, width: 1)
            Spacer()
            CaptureButton(camera: camera)
            Spacer()
            SwitchCameraButton(camera: camera)
//                .border(.primary, width: 1)
        }
        .font(.title2)
        .foregroundStyle(.theme)
        .frame(width: width, height: height)
        .padding([.leading, .trailing])
        .padding(.bottom, 24)
        .background(camera.isFramingCarouselEnabled && camera.aspectRatio == .ratio16_9 ? Color.darkGradient : .clear)
    }
    var width: CGFloat? { isRegularSize ? 250 : nil }
    var height: CGFloat? { 80 }
}

