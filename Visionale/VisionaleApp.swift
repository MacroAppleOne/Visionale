//
//  VisionaleApp.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 10/10/24.
//

import os
import SwiftUI

@main
/// The AVCam app's main entry point.
struct VisionaleApp: App {
    @StateObject private var onboardingService = OnboardingService()
    @State private var camera = CameraModel()
    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingService.hasCompletedOnboarding {
                    // Show onboarding start view
                    OnboardingStartView()
                        .environmentObject(onboardingService)
                } else if !onboardingService.cameraPermissionGranted {
                    // Show camera permission view
                    OnboardingCameraPermissionView()
                        .environmentObject(onboardingService)
                } else if !onboardingService.photoLibraryPermissionGranted {
                    // Show photo library permission view
                    OnboardingGalleryPermissionView()
                        .environmentObject(onboardingService)
                } else {
                    // All permissions granted, show main camera view
                    CameraView(camera: camera)
                        .statusBarHidden(true)
                        .task {
                            await camera.start()
                        }
                }
            }
            .onAppear {
                // Refresh permissions on app launch
                onboardingService.checkCameraPermission()
                onboardingService.checkPhotoLibraryPermission()
            }
        }
    }
}


/// A global logger for the app.
let logger = Logger()
