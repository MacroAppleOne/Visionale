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
    var saliencyHandler: SaliencyHandler = .init()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var trackedObjects: [VNDetectedObjectObservation]? = []
    var selectedKeypoints: [Int] = []
    var keypoints: [CGPoint] = [
        CGPoint(x: 0.33, y: 0.33),
        CGPoint(x: 0.67, y: 0.33),
        CGPoint(x: 0.33, y: 0.67),
        CGPoint(x: 0.67, y: 0.67),
    ]
    
    func guide(buffer: CMSampleBuffer) {
//        guard let cvPixelBuffer = saliencyHandler.convertPixelBuffer(buffer: buffer) else { return }
//        let result = saliencyHandler.detectSalientRegions(in: cvPixelBuffer, saliencyType: .attention, frameType: .center)
//        
//        self.getBoundingBoxes(buffer: buffer, saliencyType: .objectness)
//        self.findBestShotPoint(buffer: cvPixelBuffer, observation: result)
//        self.checkAlignment(shotPoint: self.bestShotPoint ?? .zero)
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
//        self.selectedKeypoint = []
//        
//        let focusPoint = self.getAttentionFocusPoint(from: observation) ?? .zero
//        let distance = keypoints.map({distanceBetween($0, and: focusPoint)})
//        let rect = self.boundingBoxes?.filter({ isInRect(rect: $0, point: focusPoint) })
//        
//        var targetPoint: CGPoint = .zero
//        var adjustmentNeededX: CGFloat = 0.0
//        var adjustmentNeededY: CGFloat = 0.0
//        
//        if rect?.count ?? 0 > 0 {
//            let width = rect?[0].width
//            let height = rect?[0].height
//            let centerX = rect?[0].midX
//            let centerY = rect?[0].midY
//            
//            print("width: \(width)")
//            print("height: \(height)")
//            
//            // If the object is large, such as crowd, use the bounding box center instead
//            if height ?? 0 > 0.33 || (height ?? 0 > 0.33 && width ?? 0 > 0.33 && height ?? 0 >= width ?? 0) {
//                print("height")
//                let leftDistance = distanceBetween(CGPoint(x: centerX ?? 0, y: 0), and: self.keypoints[0])
//                let rightDistance = distanceBetween(CGPoint(x: centerX ?? 0, y: 0), and: self.keypoints[1])
//                
//                if rightDistance > leftDistance {
//                    print("left")
//                    targetPoint = CGPoint(x: 0.33, y: 0.5)
//                    selectedKeypoint.append(0)
//                    selectedKeypoint.append(2)
//                }
//                else {
//                    print("right")
//                    targetPoint = CGPoint(x: 0.67, y: 0.5)
//                    selectedKeypoint.append(1)
//                    selectedKeypoint.append(3)
//                }
//            }
//            else if width ?? 0 > 0.33 || (height ?? 0 > 0.33 && width ?? 0 > 0.33 && height ?? 0 < width ?? 0) {
//                print("width")
//                let upperVerticalLineDistance = distanceBetween(CGPoint(x: 0, y: centerY ?? 0), and: self.keypoints[0])
//                let lowerVerticalLineDistance = distanceBetween(CGPoint(x: 0, y: centerY ?? 0), and: self.keypoints[2])
//                
//                if upperVerticalLineDistance > lowerVerticalLineDistance {
//                    targetPoint = CGPoint(x: 0.5, y: 0.67)
//                    selectedKeypoint.append(2)
//                    selectedKeypoint.append(3)
//                }
//                else {
//                    targetPoint = CGPoint(x: 0.5, y: 0.33)
//                    selectedKeypoint.append(0)
//                    selectedKeypoint.append(1)
//                }
//            }
//            else {
//                print("small")
//                guard let selectedKeyPoint = distance.firstIndex(of: distance.min()!) else { return }
//                
//                targetPoint = keypoints[selectedKeyPoint]
//                selectedKeypoint.append(selectedKeyPoint)
//            }
//        }
//        else {
//            print("no rect")
//            guard let selectedKeyPoint = distance.firstIndex(of: distance.min()!) else { return }
//            
//            targetPoint = keypoints[selectedKeyPoint]
//            selectedKeypoint.append(selectedKeyPoint)
//        }
//        
////        print(targetPoint)
////        print(CGPoint(x: adjustmentNeededX, y: adjustmentNeededY))
//        adjustmentNeededX = -(targetPoint.x - focusPoint.x)
//        adjustmentNeededY = -(targetPoint.y - focusPoint.y)
////        self.bestShotPoint = CGPoint(x: focusPoint.x + adjustmentNeededX, y: focusPoint.y + adjustmentNeededY)
//        self.bestShotPoint = focusPoint
        return nil
    }
    
    func checkAlignment(shotPoint: CGPoint) -> Bool {
//        let min = 0.5 * 0.8
//        let max = 0.5 * 1.2
//        
//        if shotPoint.x > min && shotPoint.x < max && shotPoint.y > min && shotPoint.y < max {
//            self.isAligned = true
//        }
//        else {
//            self.isAligned = false
//        }
        
        return true
    }
    
    func getBoundingBoxes(buffer: CVPixelBuffer, saliencyType: SaliencyType) -> [CGRect]? {
//        guard let cvPixelBuffer = saliencyHandler.convertPixelBuffer(buffer: buffer) else {
//            return
//        }
//        
//        let result = saliencyHandler.detectSalientRegions(in: cvPixelBuffer, saliencyType: saliencyType, frameType: .center)
//        self.boundingBoxes = result?.salientObjects?.map({$0.boundingBox})
        
        return nil
    }
    
    func startTrackingObject(buffer: CVPixelBuffer, initialObservation: VNDetectedObjectObservation) -> VNDetectedObjectObservation? {
        return nil
    }
    
    func getAttentionFocusPoint(from observation: VNSaliencyImageObservation?) -> CGPoint? {
        // Extract the pixel buffer from the observation
        guard let pixelBuffer = observation?.pixelBuffer else {
            logger.debug("Can't extract pixel buffer from observation")
            return nil
        }
        
        var focusPoint: CGPoint? = .zero
        if let heatmapCGImage = saliencyHandler.convertPixelBufferToCGImage(pixelBuffer),
           let upsampledHeatmap = upsampleSaliencyHeatmap(heatmapCGImage, to: CGSize(width: saliencyHandler.originalWidth, height: saliencyHandler.originalHeight)),
           let mostWhitePixel = getMostWhitePixel(in: upsampledHeatmap) {
            focusPoint = mostWhitePixel
        }
        
        return focusPoint
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
    
    func distanceBetween(_ point: CGPoint, and otherPoint: CGPoint) -> CGFloat {
        let dx = otherPoint.x - point.x
        let dy = otherPoint.y - point.y
        
        return sqrt(dx * dx + dy * dy)
    }
    
    func isInRect(rect: CGRect, point: CGPoint) -> Bool {
        let newWidth = rect.width * 1.2
        let newHeight = rect.height * 1.2
        
        // Calculate new origin to keep the rectangle centered
        let newX = rect.origin.x - (newWidth - rect.width) / 2
        let newY = rect.origin.y - (newHeight - rect.height) / 2
        
        let scaledRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        return rect.contains(point)
    }
}
