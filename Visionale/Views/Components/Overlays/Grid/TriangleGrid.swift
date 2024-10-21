//
//  TriangleGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct TriangleGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Base of the triangle is 3/4 of the width
            let base = width * 3 / 4
            
            // Calculate height of the equilateral triangle
            let triangleHeight = (base * sqrt(3)) / 2
            
            // Calculate positions of the triangle vertices
            let topVertex = CGPoint(x: width / 2, y: (height - triangleHeight) / 2)
            let leftVertex = CGPoint(x: (width - base) / 2, y: (height + triangleHeight) / 2)
            let rightVertex = CGPoint(x: (width + base) / 2, y: (height + triangleHeight) / 2)
            
            Path { path in
                path.move(to: topVertex) // Move to the top vertex
                path.addLine(to: leftVertex) // Draw to the left vertex
                path.addLine(to: rightVertex) // Draw to the right vertex
                path.closeSubpath() // Close the triangle path
            }
            .stroke(Color.white.opacity(0.7), lineWidth: 2) // Adjust color and width as needed
        }
    }
}

#Preview {
    TriangleGrid()
}
