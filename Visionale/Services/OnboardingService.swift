//
//  SessionManager.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 17/10/24.
//

import Foundation
import AVFoundation
import Photos
import UIKit

final class OnboardingService: ObservableObject {
    enum CurrentState {
        case onboarding
        case cameraPermissionRequest
        case photoLibraryPermissionRequest
        case app
    }
    
    @Published private(set) var currentState: CurrentState
    
    init() {
        self.currentState = .onboarding
        checkPermissions()
    }
    
    func checkPermissions() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                self.currentState = .onboarding
            } else if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                self.currentState = .cameraPermissionRequest
            } else if PHPhotoLibrary.authorizationStatus() != .authorized {
                self.currentState = .photoLibraryPermissionRequest
            } else {
                self.currentState = .app
            }
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        checkPermissions()
    }
    
    // Request Camera Permission
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            // Request permission if it hasn't been determined yet
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.checkPermissions()
                }
            }
            
        case .denied, .restricted:
            // Permission is denied, show the alert to guide user to settings
            showSettingsAlert(for: "Camera")
            
        case .authorized:
            // Permission is already granted, proceed with camera access
            checkPermissions()
            
        @unknown default:
            break
        }
    }

    // Request Photo Library Permission
    func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .notDetermined:
            // Request permission if it hasn't been determined yet
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.checkPermissions()
                }
            }
            
        case .denied, .restricted:
            // Show alert prompting the user to go to settings
            showSettingsAlert(for: "Photo Library")
            
        case .authorized, .limited:
            // Permission is already granted or limited, proceed with using the photo library
            checkPermissions()
            
        @unknown default:
            break
        }
    }

    // Show Settings Alert when permission is denied
    func showSettingsAlert(for feature: String) {
        guard let topController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "\(feature) Permission",
            message: "You have previously denied access to the \(feature). Please go to settings to allow access.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        topController.present(alert, animated: true, completion: nil)
    }
}
