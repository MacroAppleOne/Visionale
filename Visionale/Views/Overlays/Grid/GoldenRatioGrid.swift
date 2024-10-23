//
//  GoldenRatioGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct GoldenRatioGrid: View {
    var imageName = "GoldenRatio"
    @State private var aspectRatio: CGFloat = 1.612 // Aspect ratio of the image
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = height * aspectRatio // Calculate width based on height and aspect ratio
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                .frame(width: width, height: height) // Set frame
                .position(x: geometry.size.width / 2, y: height / 2) // Center horizontally
                .onAppear {
                    // Load the image and calculate the aspect ratio
                    if let uiImage = UIImage(named: imageName) {
                        aspectRatio = uiImage.size.width / uiImage.size.height
                    }
                }
        }
    }
}

#Preview {
    GoldenRatioGrid()
}
