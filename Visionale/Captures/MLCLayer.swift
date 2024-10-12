//
//  MachineLearning.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 10/10/24.
//

import CoreML
import CoreImage
import AVFoundation

//
//  VideoProcessing.swift
//  TestCameraAI
//
//  Created by Nico Samuelson on 03/10/24.
//

import CoreML
import CoreImage
import AVFoundation

@Observable
class MachineLearningClassificationLayer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let frameRecommendation: FrameRecommendation = FrameRecommendation()
    let guidanceSystem: GuidanceSystem = GuidanceSystem()
    
    var frameType: FrameType = .center
    var predictionLabels: [String] = []
    var bestShotPoint: CGPoint?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.predictionLabels = self.frameRecommendation.processFrame(sampleBuffer)
        self.bestShotPoint = self.guidanceSystem.doShotSuggestion(buffer: sampleBuffer, frameType: self.frameType)
    }
}
