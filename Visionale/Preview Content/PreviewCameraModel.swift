//
//  PreviewCameraModel.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 25/10/24.
//

/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 A Camera implementation to use when working with SwiftUI previews.
 */

import Foundation
import SwiftUI

@Observable
class PreviewCameraModel: Camera {
    var isZoomSliderEnabled: Bool = false
    
    var aspectRatio: AspectRatio = .ratio4_3
    
    func toggleAspectRatio() {
        logger.info("gg")
    }
    
    var isAspectRatioOptionEnabled: Bool = false
    
    func toggleAspectRatioOption() {
        logger.info("gg")
    }
    
    func setZoom(factor: CGFloat) async {
        logger.info("mantap")
    }
    
    func zoom(factor: CGFloat) async -> CGFloat {
        return 0.0
    }
    func setZoomFactor(_ factor: CGFloat) async -> CGFloat {
        return 0.0
    }
    var minZoomFactor: CGFloat = 0.0
    
    var maxZoomFactor: CGFloat = 0.0
    
    var isFramingCarouselEnabled: Bool = false
    
    func toggleFramingCarousel() {
        logger.info("mantap")
    }
    
    var activeComposition: String = ""
    
    var activeID: UUID? = UUID()
    
    
    func findComposition(withName name: String) {
        logger.info("mantap")
    }
    
    func updateActiveComposition(to composition: Composition) {
        logger.info("mantap")
    }
    
    var zoomFactor: CGFloat = 0.0
    
    
    func zoom(factor: CGFloat) {
        logger.info("Zoomed by \(factor)")
    }
    
    func zoomEnded() {
        logger.info("Zoom ended")
    }
    
    var mlcLayer: ImageClassificationHandler? = ImageClassificationHandler()
    
    var compositions: [Composition] = [
        Composition(name: "GG", description: "", image: "", isRecommended: true)
    ]
    
    var recommendedCompositions: [Composition] = [
        Composition(name: "GG", description: "", image: "", isRecommended: true)
    ]
    
    func findComposition(withName name: String) -> String? {
        return "mantap"
    }
    
    func updateActiveComposition(id: UUID?) {
        logger.info("blm")
    }
    
    func toggleTorch() async {
        logger.info("torch")
    }
    
    var isTorchOn: Bool = false
    
    func toggleGridOverlay() async {
        logger.info("Toggling grid overlay")
    }
    
    private(set) var isGridOverlayOn: Bool = false
    
    
    func setZoomLevel(_ zoomLevel: CGFloat) async {
        logger.info("Setting zoom level to \(zoomLevel)")
    }
    
    
    var shouldFlashScreen = false
    
    struct PreviewSourceStub: PreviewSource {
        // Stubbed out for test purposes.
        func connect(to target: PreviewTarget) {}
    }
    
    let previewSource: PreviewSource = PreviewSourceStub()
    
    private(set) var status = CameraStatus.unknown
    private(set) var captureActivity = CaptureActivity.idle
    var captureMode = CaptureMode.photo {
        didSet {
            isSwitchingModes = true
            Task {
                // Create a short delay to mimic the time it takes to reconfigure the session.
                try? await Task.sleep(until: .now + .seconds(0.3), clock: .continuous)
                self.isSwitchingModes = false
            }
        }
    }
    var zoomLevel: CGFloat = 1.0
    private(set) var isSwitchingModes = false
    private(set) var isVideoDeviceSwitchable = true
    private(set) var isSwitchingVideoDevices = false
    private(set) var photoFeatures = PhotoFeatures()
    private(set) var thumbnail: CGImage?
    
    var error: Error?
    
    init(captureMode: CaptureMode = .photo, status: CameraStatus = .unknown) {
        self.captureMode = captureMode
        self.status = status
    }
    
    func start() async {
        if status == .unknown {
            status = .running
        }
    }
    
    func switchVideoDevices() {
        logger.debug("Device switching isn't implemented in PreviewCamera.")
    }
    
    func capturePhoto() {
        logger.debug("Photo capture isn't implemented in PreviewCamera.")
    }
    
    func toggleRecording() {
        logger.debug("Moving capture isn't implemented in PreviewCamera.")
    }
    
    func focusAndExpose(at point: CGPoint) {
        logger.debug("Focus and expose isn't implemented in PreviewCamera.")
    }
    
    var recordingTime: TimeInterval { .zero }
    
    private func capabilities(for mode: CaptureMode) -> CaptureCapabilities {
        switch mode {
        case .photo:
            return CaptureCapabilities(isFlashSupported: true,
                                       isLivePhotoCaptureSupported: true)
        case .video:
            return CaptureCapabilities(isFlashSupported: false,
                                       isLivePhotoCaptureSupported: false,
                                       isHDRSupported: true)
        }
    }
}
