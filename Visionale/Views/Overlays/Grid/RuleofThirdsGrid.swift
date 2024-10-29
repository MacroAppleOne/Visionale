//
//  RuleofThirdsGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct RuleOfThirdsGrid<CameraModel: Camera>: View {
    @State var camera: CameraModel
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: width / 3, y: 0))
                    path.addLine(to: CGPoint(x: width / 3, y: height))
                }
                .stroke([1, 3].contains(camera.mlcLayer?.guidanceSystem?.selectedKeypoint) && camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 2)
                
                Path { path in
                    path.move(to: CGPoint(x: (2 * width) / 3, y: 0))
                    path.addLine(to: CGPoint(x: (2 * width) / 3, y: height))
                }
                .stroke([2, 4].contains(camera.mlcLayer?.guidanceSystem?.selectedKeypoint) && camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 2)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height / 3))
                    path.addLine(to: CGPoint(x: width, y: height / 3))
                }
                .stroke([1, 2].contains(camera.mlcLayer?.guidanceSystem?.selectedKeypoint) && camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 2)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: (2 * height) / 3))
                    path.addLine(to: CGPoint(x: width, y: (2 * height) / 3))
                }
                .stroke([3, 4].contains(camera.mlcLayer?.guidanceSystem?.selectedKeypoint) && camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 2)
            }
            
            
            
//            Path { path in
//                // Vertical lines
//                path.move(to: CGPoint(x: width / 3, y: 0))
//                path.addLine(to: CGPoint(x: width / 3, y: height))
//                path.move(to: CGPoint(x: (2 * width) / 3, y: 0))
//                path.addLine(to: CGPoint(x: (2 * width) / 3, y: height))
//                
//                // Horizontal lines
//                path.move(to: CGPoint(x: 0, y: height / 3))
//                path.addLine(to: CGPoint(x: width, y: height / 3))
//                path.move(to: CGPoint(x: 0, y: (2 * height) / 3))
//                path.addLine(to: CGPoint(x: width, y: (2 * height) / 3))
//            }
//            .stroke(Color.white.opacity(0.7), lineWidth: 2) // jangan lupa ganti warnanya
        }
    }
}

//#Preview {
//    RuleOfThirdsGrid()
//}
