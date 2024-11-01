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
    var saliencyHandler: SaliencyHandler = .init()
    private var trackingRequests: [VNTrackObjectRequest]?
    private var sequenceRequestHandler = VNSequenceRequestHandler()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var trackedObjects: [CGRect]? = []
    var selectedKeypoints: [Int] = []
    var keypoints: [CGPoint] = []

    func guide(buffer: CMSampleBuffer) {
        guard let cvPixelBuffer = saliencyHandler.convertPixelBuffer(buffer: buffer) else { return }
        
        self.bestShotPoint = self.findBestShotPoint(buffer: cvPixelBuffer)
        self.isAligned = self.checkAlignment(shotPoint: self.bestShotPoint ?? .zero)
    }
    
    func reset() {
        self.trackingRequests = nil
        self.shouldReset = true
        self.isAligned = false
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
        // MARK: SALIENCY
        if shouldReset {
            logger.debug("RESET")
            self.trackedObjects?.removeAll()
            let focusPoint = self.getAttentionFocusPoint(from: buffer) ?? .zero
            let boundingBoxes = self.getBoundingBoxes(buffer: buffer, saliencyType: .objectness)
            
            guard let boundingBoxes else {
                logger.debug("No bounding boxes found, resetting guidance system")
                reset()
                return nil
            }
            
            let rect = boundingBoxes.filter({ $0.contains(focusPoint) })
            
            // if the focus point is inside a rectangle
            if rect.count > 0 {
                let width = rect[0].width
                let height = rect[0].height
                var mainObject: CGRect = .zero
                
                // If the object in focus is large such as crowds, use the bounding box center instead
                if width > 0.5 || height > 0.5 {
                    mainObject = rect[0]
                }
                
                else {
                    let origin = CGPoint(
                        x: focusPoint.x - 0.2,
                        y: focusPoint.y - 0.2
                    )
                    let rect = CGRect(origin: origin, size: CGSize(width: 0.4, height: 0.4))
                    mainObject = rect
                }
                
                self.shouldReset = false
                self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: mainObject))]
                self.sequenceRequestHandler = VNSequenceRequestHandler()
            }
            else if !boundingBoxes.isEmpty {
                let origin = CGPoint(
                    x: focusPoint.x - 0.2,
                    y: focusPoint.y - 0.2
                )
                let rect = CGRect(origin: origin, size: CGSize(width: 0.4, height: 0.4))
                self.shouldReset = false
                self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: rect))]
                self.sequenceRequestHandler = VNSequenceRequestHandler()
            }
            else {
                reset()
                return nil
            }
        }
        
        // MARK: OBJECT TRACKING
        guard let trackResult = self.startTrackingObject(buffer: buffer) else {
            return nil
        }
        
        self.trackedObjects = [trackResult.boundingBox]
        return CGPoint(x: trackResult.boundingBox.midX, y: 1 - trackResult.boundingBox.midY)
    }
    
    func startTrackingObject(buffer: CVPixelBuffer) -> VNDetectedObjectObservation? {
        guard let requests = self.trackingRequests, !requests.isEmpty else {
            logger.debug("no tracking request is made")
            reset()
            return nil
        }
        
        do {
            try self.sequenceRequestHandler.perform(requests, on: buffer, orientation: self.saliencyHandler.imageOrientationFromDeviceOrientation())
        } catch let error as NSError {
            logger.debug("Failed to perform SequenceRequest: \(error)")
            reset()
            return nil
        }
        
        // Setup the next round of tracking.
        var newTrackingRequests = [VNTrackObjectRequest]()
        
        guard let trackingRequest = requests.first else {
            logger.debug("no tracked object is found")
            reset()
            return nil
        }
            
        guard let observation = trackingRequest.results?.first as? VNDetectedObjectObservation else {
            logger.debug("Can't get observation")
            reset()
            return nil
        }
            
        if !trackingRequest.isLastFrame {
            if observation.confidence > 0.5 {
                trackingRequest.inputObservation = observation
                trackingRequest.trackingLevel = .accurate
                newTrackingRequests.append(trackingRequest)
                self.trackingRequests = newTrackingRequests
                return observation
            } else {
                trackingRequest.isLastFrame = true
                logger.debug("Tracking lost")
                reset()
                return nil
            }
        }
        else {
            logger.debug("Last frame")
            reset()
            return nil
        }
    }
    
    func checkAlignment(shotPoint: CGPoint) -> Bool {
        let min = 0.5 * 0.8
        let max = 0.5 * 1.2
        
        if shotPoint.x > min && shotPoint.x < max && shotPoint.y > min && shotPoint.y < max {
            return true
        }
        else {
            return false
        }
    }
    
    func getBoundingBoxes(buffer: CVPixelBuffer, saliencyType: SaliencyType) -> [CGRect]? {
        let result = saliencyHandler.detectSalientRegions(in: buffer, saliencyType: .objectness, frameType: .center)
        return result?.salientObjects?.map({$0.boundingBox})
    }
    
    func getAttentionFocusPoint(from cvPixelBuffer: CVPixelBuffer) -> CGPoint? {
        guard let observation = saliencyHandler.detectSalientRegions(in: cvPixelBuffer, saliencyType: .attention, frameType: .center) else {
            logger.debug("Saliency result yield no result")
            self.shouldReset = true
            return nil
        }
        
        var attentionCenterPoint: CGPoint? = .zero
        if let heatmapCGImage = saliencyHandler.convertPixelBufferToCGImage(observation.pixelBuffer),
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
            logger.debug("Failed to get image data.")
            return nil
        }
        
        // Define the center point of the image
        let centerX = width / 2
        let centerY = height / 2
        
        // Variables to keep track of the best pixel
        var maxScore: Double = 0
        var bestPoint: CGPoint?

        // Iterate over each pixel
        for y in 0..<height {
            for x in 0..<width {
                let pixelOffset = y * bytesPerRow + x * bytesPerPixel
                let red = data[pixelOffset]
                let green = data[pixelOffset + 1]
                let blue = data[pixelOffset + 2]
                
                // Calculate brightness as the maximum of RGB components
                let brightness = max(red, green, blue)

                // Calculate distance to center, scaled between 0 and 1 (0 = center, 1 = farthest point)
                let distanceToCenter = sqrt(pow(Double(x - centerX), 2) + pow(Double(y - centerY), 2)) / sqrt(pow(Double(centerX), 2) + pow(Double(centerY), 2))
                
                // Define a score that favors brightness and proximity to the center (lower distance)
                let score = Double(brightness) * (1.0 - distanceToCenter)
                
                // Update if this pixel has a higher score
                if score > maxScore {
                    maxScore = score
                    bestPoint = CGPoint(x: CGFloat(x) / CGFloat(saliencyHandler.originalWidth), y: CGFloat(y) / CGFloat(saliencyHandler.originalHeight))
                }
            }
        }
        
        return bestPoint
    }
}
