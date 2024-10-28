//
//  CenterGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 27/10/24.
//

import Vision
import UIKit

@Observable
class CenterGuidance: GuidanceSystem {
    
    var bestShotPoint: CGPoint? = .zero
    var isAligned: Bool = false
    var saliencyHandler: SaliencyHandler = SaliencyHandler()
    var boundingBoxes: [CGRect]? = []
    
    func findBestShotPoint(buffer: CVPixelBuffer, observation: VNSaliencyImageObservation?) {
        self.bestShotPoint = self.getAttentionFocusPoint(from: observation) ?? .zero
    }
    
    func checkAlignment(shotPoint: CGPoint) {
        let min = 0.5 * 0.8
        let max = 0.5 * 1.2
        
        if shotPoint.x > min && shotPoint.x < max && shotPoint.y > min && shotPoint.y < max {
            self.isAligned = true
        }
        else {
            self.isAligned = false
        }
    }
    
    func guide(buffer: CMSampleBuffer) {
        guard let cvPixelBuffer = saliencyHandler.convertPixelBuffer(buffer: buffer) else { return }
        
        saliencyHandler.detectSalientRegions(in: cvPixelBuffer, saliencyType: .attention, frameType: .center, completion: { result in
            self.findBestShotPoint(buffer: cvPixelBuffer, observation: result)
            self.checkAlignment(shotPoint: self.bestShotPoint ?? .zero)
        })
    }
    
    func getAttentionFocusPoint(from observation: VNSaliencyImageObservation?) -> CGPoint? {
        // Extract the pixel buffer from the observation
        guard let pixelBuffer = observation?.pixelBuffer else {
            logger.debug("Can't extract pixel buffer from observation")
            return nil
        }
        
        var attentionCenterPoint: CGPoint? = .zero
        if let heatmapCGImage = saliencyHandler.convertPixelBufferToCGImage(pixelBuffer),
           let upsampledHeatmap = upsampleSaliencyHeatmap(heatmapCGImage, to: CGSize(width: saliencyHandler.originalWidth, height: saliencyHandler.originalHeight)),
           let mostWhitePixel = getMostWhitePixel(in: upsampledHeatmap) {
            attentionCenterPoint = mostWhitePixel
        }
        
        return attentionCenterPoint
    }
    
    func upsampleSaliencyHeatmap(_ heatmap: CGImage, to targetSize: CGSize) -> CGImage? {
        let ciImage = CIImage(cgImage: heatmap)
        
        // Calculate scale factors
        let scaleX = targetSize.width / CGFloat(heatmap.width)
        let scaleY = targetSize.height / CGFloat(heatmap.height)
        
        // Apply scaling using Lanczos
        let scaledImage = ciImage.applyingFilter("CILanczosScaleTransform", parameters: [
            "inputScale": min(scaleX, scaleY),
            "inputAspectRatio": scaleX / scaleY
        ])
        
        // Create a CGImage from the scaled CIImage
        let context = CIContext()
        return context.createCGImage(scaledImage, from: CGRect(origin: .zero, size: targetSize))
    }

    func getMostWhitePixel(in image: CGImage) -> CGPoint? {
        // Get image dimensions and pixel data
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = image.bytesPerRow
        guard let dataProvider = image.dataProvider,
              let pixelData = dataProvider.data,
              let data = CFDataGetBytePtr(pixelData) else {
            print("Failed to get image data.")
            return nil
        }
        
        var maxBrightness: UInt8 = 0
        var maxPoint: CGPoint?

        // Iterate through each pixel
        for y in 0..<height {
            for x in 0..<width {
                let pixelOffset = y * bytesPerRow + x * bytesPerPixel
                let red = data[pixelOffset]
                let green = data[pixelOffset + 1]
                let blue = data[pixelOffset + 2]

                // Calculate brightness (we assume full white as max brightness)
                let brightness = max(red, green, blue)

                // Update if this pixel has a higher brightness
                if brightness > maxBrightness {
                    maxBrightness = brightness
                    maxPoint = CGPoint(x: CGFloat(x) / CGFloat(saliencyHandler.originalWidth), y: CGFloat(y) / CGFloat(saliencyHandler.originalHeight))
                }
            }
        }
        
        return maxPoint
    }
    
    func getBoundingBox(buffer: CMSampleBuffer) {
        guard let cvPixelBuffer = saliencyHandler.convertPixelBuffer(buffer: buffer) else {
            return
        }
        
        saliencyHandler.detectSalientRegions(in: cvPixelBuffer, frameType: .center, completion: { result in
            self.boundingBoxes = result?.salientObjects?.map({$0.boundingBox})
        })
    }
}
