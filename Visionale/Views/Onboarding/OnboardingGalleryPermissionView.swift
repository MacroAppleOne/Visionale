//
//  OnboardingGalleryPermissionView.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 23/10/24.
//

import SwiftUI
import Photos

struct OnboardingLocationPermissionView: View {
    private var locationManager: CLLocationManager = CLLocationManager()
    @EnvironmentObject var session: OnboardingService
    @State private var showPermissionAlert = false
    var meshGradient: some View {
        MeshGradient(
            width: 5,
            height: 5,
            points: [
                // 5x5 grid points
                [0.0, 0.0], [0.25, 0.0], [0.5, 0.0], [0.75, 0.0], [1.0, 0.0],
                [0.0, 0.25], [0.25, 0.25], [0.5, 0.25], [0.75, 0.25], [1.0, 0.25],
                [0.0, 0.5], [0.25, 0.5], [0.5, 0.5], [0.75, 0.5], [1.0, 0.5],
                [0.0, 0.75], [0.25, 0.75], [0.5, 0.75], [0.75, 0.75], [1.0, 0.75],
                [0.0, 1.0], [0.25, 1.0], [0.5, 1.0], [0.75, 1.0], [1.0, 1.0]
            ],
            colors: [
                .lightGradient, .lightGradient, .lightGradient, .accentColor, .accentColor,
                .accentColor, .accentColor, .accentColor, .lightGradient, .lightGradient,
                .darkGradient.mix(with: .accentColor, by: 0.6), .accentColor, .accentColor, .accentColor, .accentColor,
                .darkGradient, .darkGradient.mix(with: .accentColor, by: 0.2), .accentColor.mix(with: .darkGradient, by: 0.7), .darkGradient.mix(with: .accentColor, by: 0.2), .darkGradient,
                .darkGradient, .darkGradient, .darkGradient, .darkGradient, .darkGradient
            ],
            smoothsColors: true
        )
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    var body: some View {
        ZStack {
            VStack{
                meshGradient
            }
            VStack {
                ZStack{
                    Rectangle()
                        .fill(.darkGradient)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    Image("locationImage")
                        .resizable()
                }
                Spacer(minLength: 50)
                VStack(alignment: .leading){
                    Text("Location Access")
                        .font(.largeTitle)
                        .foregroundColor(.lightGradient)
                        .bold()
                    Text("Visionalé fully respects your privacy. We request access to your location only to enhance your experience by providing location-specific features. Rest assured, we do not collect or store your personal data, and your location information is never shared.")
                        .font(.footnote)
                        .foregroundColor(.lightGradient)
                    Button(action: {
                        
//                                                Task{
                        locationManager.requestWhenInUseAuthorization()
                         session.requestLocationPermission()
//                                                }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.darkGradient)
                                .frame(width: 25, height: 25)
                            
                            Text("Allow Location Access")
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
                            title: Text("Location Access Denied"),
                            message: Text("Please allow location access in settings."),
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
                }.padding(.bottom,40)
                    .padding(.horizontal, 35)
            }
            .edgesIgnoringSafeArea(.all)
        }.onChange(of: session.locationPermissionGranted) { oldValue, newValue in
            session.locationPermissionGranted = newValue
        }
    }
}

#Preview {
    OnboardingGalleryPermissionView()
}
