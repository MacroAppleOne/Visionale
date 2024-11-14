//
//  HalfCircle.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 13/11/24.
//

import SwiftUI

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define the center and radius based on the rect
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        
        // Start drawing from the left bottom corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Draw the arc (half-circle)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Close the path to form a complete shape
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    HalfCircle()
}
