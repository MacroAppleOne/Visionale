//
//  DiagonalGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct DiagonalGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Diagonal line from top-left to bottom-right
                path.move(to: CGPoint(x: 0, y: 0)) // Top-left
                path.addLine(to: CGPoint(x: width, y: height)) // Bottom-right
                
                // Diagonal line from top-right to bottom-left
                path.move(to: CGPoint(x: width, y: 0)) // Top-right
                path.addLine(to: CGPoint(x: 0, y: height)) // Bottom-left
            }
            .stroke(Color.white.opacity(0.7), lineWidth: 2) // Adjust color and width as needed
        }
    }
}

#Preview {
    DiagonalGrid()
}
