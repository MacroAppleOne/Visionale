//
//  SymmetricGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 29/10/24.
//

import Vision
//import CoreML

class SymmetricGuidance: GuidanceSystem {
//    var sequenceHandler: VNSequenceRequestHandler = .init()
    var saliencyHandler: SaliencyHandler = .init()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var selectedKeypoints: [Int] = []
    var keypoints: [CGPoint] = []
    var trackedObjects: [CGRect]? = []
    
    func guide(buffer: CMSampleBuffer) {
        
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
        return nil
    }
    
    func checkAlignment(shotPoint: CGPoint) -> Bool {
        return false
    }
    
    func getBoundingBoxes(buffer: CVPixelBuffer, saliencyType: SaliencyType) -> [CGRect]? {
        return nil
    }
    
    func startTrackingObject(buffer: CVPixelBuffer) -> VNDetectedObjectObservation? {
        return nil
    }
}
