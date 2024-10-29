//
//  SaliencyHandler.swift
//  Visionalé
//
//  Created by Nico Samuelson on 27/10/24.
//

import Vision
import UIKit

class SaliencyHandler {
    var originalWidth = 0
    var originalHeight = 0
    
    func convertPixelBuffer(buffer: CMSampleBuffer) -> CVPixelBuffer? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            logger.debug("Could not get image buffer from CMSampleBuffer")
            return nil
        }
        
        if originalWidth == 0 && originalHeight == 0 {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
            
            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
                logger.debug("can't get base address")
                CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
                return nil
            }
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            self.originalWidth = width
            self.originalHeight = height
        }
        
        return pixelBuffer
    }
    
    func convertPixelBufferToCGImage(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    func detectSalientRegions(in pixelBuffer: CVPixelBuffer, saliencyType: SaliencyType = .attention, frameType: FrameType) -> VNSaliencyImageObservation? {
        // Create the appropriate VNRequest for the saliency type
        let request: VNImageBasedRequest = (saliencyType == .attention) ? VNGenerateAttentionBasedSaliencyImageRequest() : VNGenerateObjectnessBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: imageOrientationFromDeviceOrientation(), options: [:])
        
        do {
            try handler.perform([request])
            
            // Check if the request result contains a VNSaliencyImageObservation
            guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                logger.debug("Could not get saliency result")
                return nil
            }
            
            guard observation.salientObjects != nil else {
                logger.debug("No salient object detected")
                return nil
            }
            
            return observation
        } catch {
            logger.debug("Error processing saliency: \(error)")
            return nil
        }
    }
    
    func imageOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        default:
            return .right // Default to portrait if unknown
        }
    }
}
