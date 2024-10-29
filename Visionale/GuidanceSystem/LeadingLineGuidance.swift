//
//  LeadingLineGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 27/10/24.
//

import Vision
import UIKit

@Observable
class LeadingLineGuidance: GuidanceSystem {
    var selectedKeypoint: Int = -1
    var keypoints: [CGPoint] = []
    var saliencyHandler: SaliencyHandler = SaliencyHandler()
    var bestShotPoint: CGPoint? = .zero
    var isAligned: Bool = false
    
    func guide(buffer: CMSampleBuffer) {
        
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer, observation: VNSaliencyImageObservation?) {
        
    }
    
    func checkAlignment(shotPoint: CGPoint) {
        
    }
    
    func getBoundingBoxes(buffer: CMSampleBuffer, saliencyType: SaliencyType) {
        
    }
}
