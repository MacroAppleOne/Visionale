//
//  Carousel.swift
//  AVCam
//
//  Created by Kyrell Leano Siauw on 22/10/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

struct Carousel<CameraModel: Camera>: View {
    @State var camera: CameraModel
    
    var body: some View {
        ZStack {
            HalfCircleShape()
                .fill(Color.circle)
                .opacity(0.7)
                .frame(
                    width: UIScreen.main.bounds.width + 10,
                    height: UIScreen.main.bounds.height / 2 + 35
                )
            
            ScrollView(.horizontal) {
                HStack(spacing: -7) {
                    ForEach(camera.compositions) { composition in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                camera.activeID = composition.id
                            }
                        }) {
                            VStack {
                                Image(composition.imageName(isActive: camera.activeID == composition.id))
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            }
                            .frame(width: 80, height: 150)
                            .scaleEffect(camera.activeID == composition.id ? 1.24 : 1.0)
                            .visualEffect {
                                view, proxy in view
                                    .offset(y: offset(proxy))
                                    .offset(y: scale(proxy) * 2)
                            }
                            .scrollTransition(.interactive, axis: .horizontal) {
                                view, phase in view
                            }
                            .animation(.easeInOut(duration: 0.4), value: camera.activeID)
                        }
                    }
                }
            }
            .offset(y: -40)
            .scrollTargetLayout()
            .safeAreaPadding((UIScreen.main.bounds.width - 70) / 2)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $camera.activeID)
            .onChange(of: camera.activeID) { _, newID in
                camera.updateActiveComposition(id: newID)
            }
            .onChange(of: (camera.mlcLayer?.predictionLabels) ?? "Unknown") { _, newComposition in
                camera.findComposition(withName: newComposition)
            }
            
            // Use camera.activeComposition directly
            Text(camera.activeComposition)
                .foregroundColor(.darkGradient)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(8)
                .background(Color.base)
                .background(Material.thin)
                .cornerRadius(4)
                .offset(y: -100)
        }
    }
    
    // Circular Slider View Offset
    nonisolated func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return progress < 0 ? progress * -27 : progress * 27
    }
    
    nonisolated func scale(_ proxy: GeometryProxy) -> CGFloat {
        let progress = min(max(progress(proxy), -1), 1)
        return progress < 0 ? 1 + progress : 1 - progress
    }
    
    nonisolated func progress(_ proxy: GeometryProxy) -> CGFloat {
        let viewWidth = proxy.size.width
        let minX = (proxy.bounds(of: .scrollView)?.minX ?? 0)
        return minX / viewWidth
    }
}


// Custom Half Circle Shape
struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path
            .addArc(
                center: CGPoint(
                    x: rect.midX,
                    y: rect.maxY
                ),
                // Center at bottom
                radius: rect.width * 0.75,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

extension Composition {
    func imageName(isActive: Bool) -> String {
        switch (isActive, isRecommended) {
        case (true, true):
            return imageSelectedRecommended
        case (true, false):
            return imageSelected
        case (false, true):
            return imageRecommended
        case (false, false):
            return image
        }
    }
}

#Preview {
    Carousel(camera: CameraModel())
}
