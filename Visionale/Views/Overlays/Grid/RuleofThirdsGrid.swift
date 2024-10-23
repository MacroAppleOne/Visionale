//
//  RuleofThirdsGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct RuleOfThirdsGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Vertical lines
                path.move(to: CGPoint(x: width / 3, y: 0))
                path.addLine(to: CGPoint(x: width / 3, y: height))
                path.move(to: CGPoint(x: (2 * width) / 3, y: 0))
                path.addLine(to: CGPoint(x: (2 * width) / 3, y: height))
                
                // Horizontal lines
                path.move(to: CGPoint(x: 0, y: height / 3))
                path.addLine(to: CGPoint(x: width, y: height / 3))
                path.move(to: CGPoint(x: 0, y: (2 * height) / 3))
                path.addLine(to: CGPoint(x: width, y: (2 * height) / 3))
            }
            .stroke(Color.white.opacity(0.7), lineWidth: 2) // jangan lupa ganti warnanya
        }
    }
}

#Preview {
    RuleOfThirdsGrid()
}
