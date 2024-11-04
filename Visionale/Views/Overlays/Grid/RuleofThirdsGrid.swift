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
            
            let rectSize = width / 8
            
            let xOffset = (width - rectSize) / 2
            let yOffset = (height - rectSize) / 2
            
            ZStack {
                // Left Vertical
                Path { path in
                    path.move(to: CGPoint(x: width / 3, y: 0))
                    path.addLine(to: CGPoint(x: width / 3, y: height))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
                
                // Right Vertical
                Path { path in
                    path.move(to: CGPoint(x: (2 * width) / 3, y: 0))
                    path.addLine(to: CGPoint(x: (2 * width) / 3, y: height))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
                
                // Upper Horizontal
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height / 3))
                    path.addLine(to: CGPoint(x: width, y: height / 3))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
                
                // Lower Horizontal
                Path { path in
                    path.move(to: CGPoint(x: 0, y: (2 * height) / 3))
                    path.addLine(to: CGPoint(x: width, y: (2 * height) / 3))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
                
                Path { path in
                    path.addEllipse(in: CGRect(x: xOffset, y: yOffset, width: rectSize, height: rectSize))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
            }
            
//            Path { path in
//            path.addEllipse(in: CGRect(x: 0.28426*width, y: 0.29545*height, width: 0.10152*width, height: 0.07576*height))
//            path.addEllipse(in: CGRect(x: 0.28426*width, y: 0.62879*height, width: 0.10152*width, height: 0.07576*height))
//            path.addEllipse(in: CGRect(x: 0.61421*width, y: 0.29545*height, width: 0.10152*width, height: 0.07576*height))
//            path.addEllipse(in: CGRect(x: 0.61421*width, y: 0.62879*height, width: 0.10152*width, height: 0.07576*height))
//            path.move(to: CGPoint(x: 0.33503*width, y: 0))
//            path.addLine(to: CGPoint(x: 0.33503*width, y: 0.29545*height))
//            path.move(to: CGPoint(x: 0.33503*width, y: 0.70455*height))
//            path.addLine(to: CGPoint(x: 0.33503*width, y: height))
//            path.move(to: CGPoint(x: 0.66497*width, y: 0.70455*height))
//            path.addLine(to: CGPoint(x: 0.66497*width, y: height))
//            path.move(to: CGPoint(x: 0.66497*width, y: 0))
//            path.addLine(to: CGPoint(x: 0.66497*width, y: 0.29545*height))
//            path.move(to: CGPoint(x: 0.66497*width, y: 0.37121*height))
//            path.addLine(to: CGPoint(x: 0.66497*width, y: 0.62879*height))
//            path.move(to: CGPoint(x: 0.33503*width, y: 0.37121*height))
//            path.addLine(to: CGPoint(x: 0.33503*width, y: 0.62879*height))
//            path.move(to: CGPoint(x: 0.28426*width, y: 0.33333*height))
//            path.addLine(to: CGPoint(x: 0, y: 0.33333*height))
//            path.move(to: CGPoint(x: 0.28426*width, y: 0.66667*height))
//            path.addLine(to: CGPoint(x: 0, y: 0.66667*height))
//            path.move(to: CGPoint(x: width, y: 0.66667*height))
//            path.addLine(to: CGPoint(x: 0.71574*width, y: 0.66667*height))
//            path.move(to: CGPoint(x: width, y: 0.33333*height))
//            path.addLine(to: CGPoint(x: 0.71574*width, y: 0.33333*height))
//            path.move(to: CGPoint(x: 0.61421*width, y: 0.66667*height))
//            path.addLine(to: CGPoint(x: 0.38579*width, y: 0.66667*height))
//            path.move(to: CGPoint(x: 0.61421*width, y: 0.33333*height))
//            path.addLine(to: CGPoint(x: 0.38579*width, y: 0.33333*height))
//        }
//        .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//        
//        Path { path in
//            path.addEllipse(in: CGRect(x: 0.28426*width, y: 0.29545*height, width: 0.10152*width, height: 0.07576*height))
//        }
//        .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//        
//        Path { path in
//            path.addEllipse(in: CGRect(x: 0.28426*width, y: 0.62879*height, width: 0.10152*width, height: 0.07576*height))
//        }
//        .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//        
//        Path { path in
//            path.addEllipse(in: CGRect(x: 0.61421*width, y: 0.29545*height, width: 0.10152*width, height: 0.07576*height))
//        }
//        .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//        
//        Path { path in
//            path.addEllipse(in: CGRect(x: 0.61421*width, y: 0.62879*height, width: 0.10152*width, height: 0.07576*height))
//        }
//        .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
            
//            
//            ZStack {
//                // Left Vertical
//                Path { path in
//                    path.move(to: CGPoint(x: width / 3, y: 0))
//                    path.addLine(to: CGPoint(x: width / 3, y: height))
//                }
//                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//                
//                // Right Vertical
//                Path { path in
//                    path.move(to: CGPoint(x: (2 * width) / 3, y: 0))
//                    path.addLine(to: CGPoint(x: (2 * width) / 3, y: height))
//                }
//                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//                
//                // Upper Horizontal
//                Path { path in
//                    path.move(to: CGPoint(x: 0, y: height / 3))
//                    path.addLine(to: CGPoint(x: width, y: height / 3))
//                }
//                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//                
//                // Lower Horizontal
//                Path { path in
//                    path.move(to: CGPoint(x: 0, y: (2 * height) / 3))
//                    path.addLine(to: CGPoint(x: width, y: (2 * height) / 3))
//                }
//                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned == true ? Color.accent.opacity(0.7) : Color.white.opacity(0.7), lineWidth: 1)
//            }
        }
    }
}

//#Preview {
//    RuleOfThirdsGrid()
//}
