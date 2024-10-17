//
//  SessionManager.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 17/10/24.
//

import Foundation
import AVFoundation
import Photos

final class SessionManager: ObservableObject {
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
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.checkPermissions()
            }
        }
    }
    
    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.checkPermissions()
            }
        }
    }
}
