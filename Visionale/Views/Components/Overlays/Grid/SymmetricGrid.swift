//
//  SymmetricGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct SymmetricGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Vertical center line
                path.move(to: CGPoint(x: width / 2, y: 0))
                path.addLine(to: CGPoint(x: width / 2, y: height))
                
                // Horizontal center line
                path.move(to: CGPoint(x: 0, y: height / 2))
                path.addLine(to: CGPoint(x: width, y: height / 2))
            }
            .stroke(Color.white.opacity(0.7), lineWidth: 2) // ganti warnanya
        }
    }
}

#Preview {
    SymmetricGrid()
}
