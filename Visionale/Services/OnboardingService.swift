//
//  OnboardingService.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 23/10/24.
//

import SwiftUI
import AVFoundation
import Photos


final class OnboardingService: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var cameraPermissionGranted: Bool
    @Published var photoLibraryPermissionGranted: Bool

    init() {
        // Check if onboarding has been completed
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Initialize permissions
        self.cameraPermissionGranted = false
        self.photoLibraryPermissionGranted = false
        
        // Check current permissions
        checkCameraPermission()
        checkPhotoLibraryPermission()
    }
    
    // MARK: - Onboarding Completion
    func completeOnboarding() {
        self.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Camera Permission
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        self.cameraPermissionGranted = (status == .authorized)
    }
    
    func requestCameraPermission(completion: (() -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
                completion?()
            }
        }
    }
    
    // MARK: - Photo Library Permission
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        self.photoLibraryPermissionGranted = (status == .authorized || status == .limited)
    }
    
    func requestPhotoLibraryPermission(completion: (() -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.photoLibraryPermissionGranted = (status == .authorized || status == .limited)
                completion?()
            }
        }
    }
}
