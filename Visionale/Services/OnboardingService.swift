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
class LocationManager: NSObject, CLLocationManagerDelegate {
    var hasCompletedOnboarding: Bool
    var cameraPermissionGranted: Bool
    var photoLibraryPermissionGranted: Bool
    var hasCompletedWalkthrough: Bool
    var locationPermissionGranted: Bool
    
    var location: CLLocation? = nil
    
    private let locationManager = CLLocationManager()
    
    override init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasCompletedWalkthrough = UserDefaults.standard.bool(forKey: "hasCompletedWalkthrough")
        
        // Initialize permissions
        self.cameraPermissionGranted = false
        self.photoLibraryPermissionGranted = false
        self.locationPermissionGranted = false
        

        super.init()
        // Check current permissions
        checkCameraPermission()
        checkPhotoLibraryPermission()
        checkLocationPermission()
        locationManager.delegate = self
        
    }
    
    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        self.location = location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            self.locationPermissionGranted = false
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationPermissionGranted = true
        @unknown default:
            break
        }
    }
    
    // MARK: - Onboarding Completion
    func completeOnboarding() {
        self.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Walkthrough Completion
    func completeWalkthrough() {
        self.hasCompletedWalkthrough = true
        UserDefaults.standard.set(true, forKey: "hasCompletedWalkthrough")
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
    func checkLocationPermission() {
        DispatchQueue.global().async{
            
//            let status = CLLocationManager.authorizationStatus()
            if CLLocationManager.locationServicesEnabled() {

                switch (CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    self.locationPermissionGranted = false
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationPermissionGranted = true
                @unknown default:
                    break
                }
            }
        }
    }
    
}

final class OnboardingService: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var cameraPermissionGranted: Bool
    @Published var photoLibraryPermissionGranted: Bool
    @Published var hasCompletedWalkthrough: Bool
    @Published var locationPermissionGranted: Bool
    
    //Location Permission
    private var locationManager: CLLocationManager = CLLocationManager()
    
    init() {
        // Check if onboarding has been completed
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasCompletedWalkthrough = UserDefaults.standard.bool(forKey: "hasCompleteWalkthrough")
        
        // Initialize permissions
        self.cameraPermissionGranted = false
        self.photoLibraryPermissionGranted = false
        self.locationPermissionGranted = false
        
        // Check current permissions
        checkCameraPermission()
        checkPhotoLibraryPermission()
        checkLocationPermission()
        
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
    func checkLocationPermission() {
        DispatchQueue.global().async{
            
//            let status = CLLocationManager.authorizationStatus()
            if CLLocationManager.locationServicesEnabled() {

                switch (CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    self.locationPermissionGranted = false
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationPermissionGranted = true
                @unknown default:
                    break
                }
            }
        }
    }
    //Coba lihat link ini
    //https://holyswift.app/the-new-way-to-get-current-user-location-in-swiftu-tutorial/
    
    func sapiman()async throws {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func sapiman2()async throws {
        self.locationPermissionGranted = (self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse)
    }
    
    func requestLocationPermission(completion: (() -> Void)? = nil) {
        
        
        Task{
            try? await self.locationManager.requestWhenInUseAuthorization()
//            print(s)
            self.locationPermissionGranted = (self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse)
            completion?()
        }
        
        //        // Check permission status after request
        //        DispatchQueue.main.async {
        //            self?.checkLocationPermission()
        //            completion?()
        //        }
    }
}
