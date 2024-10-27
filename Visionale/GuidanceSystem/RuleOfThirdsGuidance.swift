//
//  RuleOfThirdsGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 27/10/24.
//

import Vision
import UIKit

@Observable
class RuleOfThirdsGuidance: GuidanceSystem {
    var saliencyHandler: SaliencyHandler = SaliencyHandler()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    
    func findBestShotPoint(buffer: CVPixelBuffer, observation: VNSaliencyImageObservation?) {
        
    }
    
    func checkAlignment(shotPoint: CGPoint) {
        
    }
    
    func guide(buffer: CMSampleBuffer) {
        
    }
    
    func getBoundingBox(buffer: CMSampleBuffer) {
        
    }
    
    
}
