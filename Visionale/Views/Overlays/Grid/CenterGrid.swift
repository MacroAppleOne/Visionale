//
//  CenterGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct CenterGrid<CameraModel: Camera>: View {
    @State var camera: CameraModel
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            let rectSize = width / 4
            
            let xOffset = (width - rectSize) / 2
            let yOffset = (height - rectSize) / 2
            
            Path { path in
                // Draw the center rectangle
                path.addRect(CGRect(x: xOffset, y: yOffset, width: rectSize, height: rectSize))
            }
            .stroke(camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1) // Adjust color and width as needed
        }
    }
}

//#Preview {
//    CenterGrid(isAligned: .constant(false))
//}
