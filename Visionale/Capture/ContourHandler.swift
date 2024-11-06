//
//  ContourHandler.swift
//  Visionale
//
//  Created by Nico Samuelson on 06/11/24.
//

import Vision
import UIKit

class ContourHandler {
    var originalWidth = 0
    var originalHeight = 0
    
    func convertPixelBuffer(buffer: CMSampleBuffer) -> CVPixelBuffer? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            logger.debug("Could not get image buffer from CMSampleBuffer")
            return nil
        }
        
        if originalWidth == 0 && originalHeight == 0 {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
            
            guard CVPixelBufferGetBaseAddress(pixelBuffer) != nil else {
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
    
    func detectContour(in pixelBuffer: CVPixelBuffer) -> VNContoursObservation? {
        let request = VNDetectContoursRequest()
        request.contrastAdjustment = 1.0
        request.detectsDarkOnLight = true
        
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: imageOrientationFromDeviceOrientation(),
            options: [:]
        )
        
        do {
            try handler.perform([request])
            
            // Check if the request result contains a VNContoursObservation
            guard let observation = request.results?.first as? VNContoursObservation else {
                logger.debug("Could not get saliency result")
                return nil
            }
            
            guard observation.contourCount > 0 else {
                logger.debug("No contour detected")
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
