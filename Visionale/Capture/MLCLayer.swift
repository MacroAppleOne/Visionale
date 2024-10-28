//
//  MachineLearning.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 10/10/24.
//

import CoreML
import CoreImage
import AVFoundation

/// A class responsible for handling machine learning classification tasks.
@Observable
final class MachineLearningClassificationLayer: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var frameRecommendation: FrameRecommendation = FrameRecommendation()
    var guidanceSystem: GuidanceSystem? = CenterGuidance()
    
    var predictionLabel: String? = ""
    private var lastProcessingTime: Date = Date(timeIntervalSince1970: 0)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Get current time
        let currentTime = Date()

        // Check if at least 1 second has passed since last processing
        if currentTime.timeIntervalSince(lastProcessingTime) < 0.5 {
            // Less than 0.5 second has passed, skip processing
            return
        }

        // Update last processing time
        lastProcessingTime = currentTime
        
        // Frame Recommendation
        self.predictionLabel = self.frameRecommendation.processFrame(sampleBuffer)
        
        // Guidance System
        self.guidanceSystem?.guide(buffer: sampleBuffer)
        self.guidanceSystem?.getBoundingBox(buffer: sampleBuffer)
    }
    
    func setGuidanceSystem(_ guidanceSystem: GuidanceSystem?) {
        self.guidanceSystem = guidanceSystem
    }
}
