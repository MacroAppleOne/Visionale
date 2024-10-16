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
    @State private var camera = CameraViewModel()
    var body: some Scene {
        WindowGroup {
            CameraView(camera: camera)
                .statusBarHidden(true)
                .task { 
                    // Start the capture pipeline.
                    await camera.start()
                }
        }
    }
}

let logger = Logger()
