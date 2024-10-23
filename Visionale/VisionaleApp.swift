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
    @State private var camera = CameraModel()
    var body: some Scene {
        WindowGroup {
            CameraView(camera: camera)
                .statusBarHidden(true)
                .task {
                    await camera.start()
                }
        }
    }
}

/// A global logger for the app.
let logger = Logger()
