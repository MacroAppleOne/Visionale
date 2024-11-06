//
//  GoldenRatioGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct GoldenRatioGrid<CameraModel: Camera>: View {
    @State var camera: CameraModel
    
    var body: some View {
        GeometryReader { gr in
            let width = gr.size.width
            let height = gr.size.height
            
            let rectSize = width / 8
            
            let xOffset = (width - rectSize) / 2
            let yOffset = (height - rectSize) / 2
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0.23681*width, y: 0.72668*height))
                    path.addCurve(to: CGPoint(x: 0.26606*width, y: 0.70853*height), control1: CGPoint(x: 0.23681*width, y: 0.71666*height), control2: CGPoint(x: 0.24992*width, y: 0.70853*height))
                    path.move(to: CGPoint(x: 0.29531*width, y: 0.76298*height))
                    path.addCurve(to: CGPoint(x: 0.23681*width, y: 0.72668*height), control1: CGPoint(x: 0.26302*width, y: 0.76298*height), control2: CGPoint(x: 0.23681*width, y: 0.74674*height))
                    path.move(to: CGPoint(x: 0.38302*width, y: 0.70855*height))
                    path.addCurve(to: CGPoint(x: 0.29528*width, y: 0.763*height), control1: CGPoint(x: 0.38302*width, y: 0.73861*height), control2: CGPoint(x: 0.34375*width, y: 0.763*height))
                    path.move(to: CGPoint(x: 0.23681*width, y: 0.61781*height))
                    path.addCurve(to: CGPoint(x: 0.38302*width, y: 0.70853*height), control1: CGPoint(x: 0.31758*width, y: 0.61781*height), control2: CGPoint(x: 0.38302*width, y: 0.65844*height))
                    path.move(to: CGPoint(x: 0.00286*width, y: 0.76298*height))
                    path.addCurve(to: CGPoint(x: 0.23681*width, y: 0.61781*height), control1: CGPoint(x: 0.00286*width, y: 0.68281*height), control2: CGPoint(x: 0.10761*width, y: 0.61781*height))
                    path.move(to: CGPoint(x: 0.38302*width, y: 0.99887*height))
                    path.addCurve(to: CGPoint(x: 0.00286*width, y: 0.76298*height), control1: CGPoint(x: 0.17306*width, y: 0.99887*height), control2: CGPoint(x: 0.00286*width, y: 0.89326*height))
                    path.move(to: CGPoint(x: 0.00286*width, y: 0.00099*height))
                    path.addCurve(to: CGPoint(x: 0.99714*width, y: 0.61796*height), control1: CGPoint(x: 0.55199*width, y: 0.00099*height), control2: CGPoint(x: 0.99714*width, y: 0.27721*height))
                    path.move(to: CGPoint(x: 0.99714*width, y: 0.61796*height))
                    path.addCurve(to: CGPoint(x: 0.38302*width, y: 0.99903*height), control1: CGPoint(x: 0.99714*width, y: 0.82842*height), control2: CGPoint(x: 0.72219*width, y: 0.99903*height))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.5), lineWidth: 1)
                
                Path { path in
                    path.addEllipse(in: CGRect(x: xOffset, y: yOffset, width: rectSize, height: rectSize))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.5), lineWidth: 1)
                .backgroundStyle(.clear)
            }
            
        }
    }
}

#Preview {
    //    GoldenRatioGrid()
}
