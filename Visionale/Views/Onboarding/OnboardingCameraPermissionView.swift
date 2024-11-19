//
//  OnboardingCameraPermissionView.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 23/10/24.
//

import SwiftUI
import AVFoundation

struct OnboardingCameraPermissionView: View {
    @EnvironmentObject var session: OnboardingService
    @State private var showPermissionAlert = false
    
    var body: some View {
        ZStack {
            VStack {
                MeshGradient(
                    width: 5,
                    height: 5,
                    points: [
                        // 5x5 grid points
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
                        .darkGradient.mix(with: .accentColor, by: 0.6), .accentColor, .accentColor, .accentColor, .accentColor,    // Third row colors
                        .darkGradient, .darkGradient.mix(with: .accentColor, by: 0.2), .accentColor.mix(with: .darkGradient, by: 0.7), .darkGradient.mix(with: .accentColor, by: 0.2), .darkGradient,  // Fourth row colors
                        .darkGradient, .darkGradient, .darkGradient, .darkGradient, .darkGradient  // Bottom row colors
                    ],
                    smoothsColors: true
                ).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.darkGradient)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    Image("cameraImage")
                        .resizable()
                }
                
                Spacer(minLength: 50)
                
                VStack(alignment: .leading) {
                    Text("Camera Access")
                        .font(.largeTitle)
                        .foregroundColor(.lightGradient)
                        .bold()
                    
                    Text("Visionalé fully respects your privacy. We only request access to your camera to ensure the app functions properly, without collecting your personal data.")
                        .font(.footnote)
                        .foregroundColor(.lightGradient)
                    
                    Button(action: {
                        session.requestCameraPermission {
                            if !session.cameraPermissionGranted {
                                showPermissionAlert = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.darkGradient)
                                .frame(width: 25, height: 25)
                            
                            Text("Allow Camera Access")
                                .foregroundColor(.darkGradient)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.accent)
                        .cornerRadius(50)
                        .shadow(radius: 5)
                    }
                    .alert(isPresented: $showPermissionAlert) {
                        Alert(
                            title: Text("Camera Access Denied"),
                            message: Text("Please allow camera access in settings."),
                            primaryButton: .default(Text("Settings"), action: {
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                                   UIApplication.shared.canOpenURL(settingsURL) {
                                    UIApplication.shared.open(settingsURL)
                                }
                            }),
                            secondaryButton: .cancel()
                        )
                    }
                    .padding(.vertical, 100)
                }
                .padding(.bottom, 60)
                .padding(.horizontal, 35)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    OnboardingCameraPermissionView()
}
