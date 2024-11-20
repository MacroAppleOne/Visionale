//
//  OnboardingService.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 23/10/24.
//

import SwiftUI
import AVFoundation
import Photos
import CoreLocation
import Observation

@Observable
final class OnboardingService: NSObject,ObservableObject, CLLocationManagerDelegate {
    var hasCompletedOnboarding: Bool
    var cameraPermissionGranted: Bool
    var photoLibraryPermissionGranted: Bool
    var hasCompletedWalkthrough: Bool
    var locationPermissionGranted: Bool
    
    //Location Permission
    var manager: CLLocationManager = CLLocationManager()
    
    override init() {
        // Check if onboarding has been completed
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasCompletedWalkthrough = UserDefaults.standard.bool(forKey: "hasCompleteWalkthrough")
        
        // Initialize permissions
        self.cameraPermissionGranted = false
        self.photoLibraryPermissionGranted = false
        self.locationPermissionGranted = false
        
        super.init()
        // Check current permissions
        checkCameraPermission()
        checkPhotoLibraryPermission()
//        checkLocationPermission()
        locationManagerDidChangeAuthorization(manager)
        manager.delegate = self
    }
    
    // MARK: - Onboarding Completion
    func completeOnboarding() {
        self.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Walkthrough Completion
    func completeWalkthrough() {
        self.hasCompletedWalkthrough = true
        UserDefaults.standard.set(true, forKey: "hasCompleteWalkthrough")
    }
    
    func toggleWalkthrough(){
        self.hasCompletedWalkthrough.toggle()
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
    
    // MARK: - Location Permission
//    func checkLocationPermission() {
//        switch self.manager.authorizationStatus {
//        case .authorizedWhenInUse, .authorizedAlways:  // Location services are available.
//            self.locationPermissionGranted = true
//            break
//            
//        case .restricted, .denied, .notDetermined:  // Location services currently unavailable.
//            self.locationPermissionGranted = false
//            break
////        case .notDetermined:        // Authorization not determined yet.
////            manager.requestWhenInUseAuthorization()
////            break
//        default:
//            break
//        }
//    }
    
    func requestLocationPermission(/*completion: (() -> Void)? = nil*/) {
        //        Task{
        self.manager.requestWhenInUseAuthorization()
//        self.checkLocationPermission()
        //                self.locationPermissionGranted =
//        completion?()
        //        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch self.manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:  // Location services are available.
            self.locationPermissionGranted = true
            print(locationPermissionGranted)
            break
            
        case .restricted, .denied, .notDetermined:  // Location services currently unavailable.
            self.locationPermissionGranted = false
            break
//        case .notDetermined:        // Authorization not determined yet.
//            manager.requestWhenInUseAuthorization()
//            break
        default:
            break
        }
        
        
    }
    
    
    
    //    func checkLocationPermission() {
    //        locationManager.delegate = self
    //        switch CLLocationManager.authorizationStatus() {
    //        case .authorizedAlways, .authorizedWhenInUse:
    //            locationPermissionGranted = true
    //        case .notDetermined:
    //            locationManager.requestWhenInUseAuthorization()
    //            locationPermissionGranted = false
    //        case .restricted, .denied:
    //            locationPermissionGranted = false
    //        @unknown default:
    //            locationPermissionGranted = false
    //        }
    //    }
    //
    //    @objc(locationManager:didChangeAuthorizationStatus:) func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //        if status == .authorizedAlways || status == .authorizedWhenInUse {
    //            locationPermissionGranted = true
    //        } else {
    //            locationPermissionGranted = false
    //        }
    //    }
    //
    //
    
}
