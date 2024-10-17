//
//  VisionaleApp.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 10/10/24.
//

import SwiftUI
import os

@main
struct VisionaleApp: App {
    // AppStorage for onboarding
    @StateObject private var session = OnboardingService()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(session)
        }
    }
}

let logger = Logger()
