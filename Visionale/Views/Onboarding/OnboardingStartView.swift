//
//  OnboardingStartView.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 17/10/24.
//

import SwiftUI

struct OnboardingStartView: View {
    @EnvironmentObject var session: OnboardingService

    @State private var isActive = false
    var body: some View {
        if isActive{
            OnboardingInformationView()
        } else {
            VStack(spacing: 0) {
                ZStack{
                    MeshGradient(
                        width: 5,
                        height: 5,
                        points: [
                            // 5x5 grid points: 5 rows, 5 points per row
                            [0.0, 0.0], [0.25, 0.0], [0.5, 0.0], [0.75, 0.0], [1.0, 0.0],  // Top row
                            [0.0, 0.25], [0.25, 0.25], [0.5, 0.25], [0.75, 0.25], [1.0, 0.25],  // Second row
                            [0.0, 0.5], [0.25, 0.5], [0.5, 0.5], [0.75, 0.5], [1.0, 0.5],  // Third row
                            [0.0, 0.75], [0.25, 0.75], [0.5, 0.75], [0.75, 0.75], [1.0, 0.75],  // Fourth row
                            [0.0, 1.0], [0.25, 1.0], [0.5, 1.0], [0.75, 1.0], [1.0, 1.0]   // Bottom row
                        ],
                        colors: [
                            // Corresponding colors for each point in the 5x5 grid
                            .lightGradient, .lightGradient, .lightGradient, .accentColor, .accentColor,   // Top row colors
                            .accentColor, .accentColor, .accentColor, .lightGradient, .lightGradient,  // Second row colors
                            .accentColor, .accentColor, .accentColor, .accentColor, .accentColor,    // Third row colors
                            .darkGradient, .darkGradient.mix(with: .accentColor, by: 0.2), .accentColor.mix(with: .darkGradient, by: 0.7), .darkGradient.mix(with: .accentColor, by: 0.2), .darkGradient,  // Fourth row colors
                            .darkGradient, .darkGradient, .darkGradient, .darkGradient, .darkGradient  // Bottom row colors
                        ]
                    )
                    VStack{
                        Image("rot_recom").resizable()
                            .renderingMode(.template)
                            .foregroundColor(.red)
                            .frame(width: 75, height: 75)
                    }
                    .padding([.leading], 50)
                    .padding([.top], 125)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    VStack(alignment: .leading){
                        Text("Visionalé")
                            .font(.largeTitle)
                            .foregroundColor(.lightGradient)
                            .bold()
                        Text("Camera")
                            .font(.largeTitle)
                            .foregroundColor(.lightGradient)
                            .bold()
                        Text("Application")
                            .font(.largeTitle)
                            .foregroundColor(.lightGradient)
                            .bold()
                    }
                    .padding([.leading], 50)
                    .padding([.bottom], 125)// Add padding to ensure text doesn't touch edges
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading) // Aligns to bottom left
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
        }
    }
}
#Preview {
    OnboardingStartView()
}
