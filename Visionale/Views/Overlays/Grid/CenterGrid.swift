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
            
            let centerRectWidth = width / 3
            let centerRectHeight = height / 3
            
            let xOffset = (width - centerRectWidth) / 2
            let yOffset = (height - centerRectHeight) / 2
            
            Path { path in
                // Draw the center rectangle
                path.addRect(CGRect(x: xOffset, y: yOffset, width: centerRectWidth, height: centerRectHeight))
            }
            .stroke(camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 2) // Adjust color and width as needed
        }
    }
}

//#Preview {
//    CenterGrid(isAligned: .constant(false))
//}
