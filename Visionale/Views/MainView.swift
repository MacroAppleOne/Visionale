//
//  SplashScreen.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 17/10/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: OnboardingService
    var body: some View {
        Group {
            switch session.currentState {
            case .onboarding:
                OnboardingInformationView()
            case .cameraPermissionRequest:
                OnboardingCameraPermissionView()
            case .photoLibraryPermissionRequest:
                OnboardingGalleryPermissionView()
            case .app:
                CameraView()
            }
        }
        .onAppear {
            session.checkPermissions()
        }
        .onChange(of: UIApplication.shared.applicationState) { oldState, newState in
            if newState == .active {
                session.checkPermissions()
            }
        }
        .animation(.easeInOut, value: session.currentState)
    }
}

#Preview {
    MainView()
}
