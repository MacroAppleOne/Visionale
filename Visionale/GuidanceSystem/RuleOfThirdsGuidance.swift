//
//  RuleOfThirdsGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 27/10/24.
//

import Vision
import UIKit

enum ObjectType {
    case wide
    case tall
    case wideAndTall
}

@Observable
class RuleOfThirdsGuidance: GuidanceSystem {
    var saliencyHandler: SaliencyHandler = .init()
    var tracker: VNTrackObjectRequest? = nil
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var trackedObjects: [VNDetectedObjectObservation]? = []
    var selectedKeypoints: [Int] = []
    var targetPoint: CGPoint = .zero
    var keypoints: [CGPoint] = [
        CGPoint(x: 0.33, y: 0.33),
        CGPoint(x: 0.67, y: 0.33),
        CGPoint(x: 0.33, y: 0.67),
        CGPoint(x: 0.67, y: 0.67),
    ]
    
    func guide(buffer: CMSampleBuffer) {
        guard let cvPixelBuffer = saliencyHandler.convertPixelBuffer(buffer: buffer) else { return }
        
        self.bestShotPoint = self.findBestShotPoint(buffer: cvPixelBuffer)
        self.isAligned = self.checkAlignment(shotPoint: self.bestShotPoint ?? .zero)
    }
    
    func resetTrackerAndGuidance() {
        self.shouldReset = true
        self.tracker = nil
        self.trackedObjects?.removeAll()
        self.selectedKeypoints.removeAll()
        self.targetPoint = .zero
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
        // MARK: SALIENCY
        if shouldReset {
            resetTrackerAndGuidance()
            self.trackedObjects?.removeAll()
            self.selectedKeypoints.removeAll()
            
            let focusPoint = self.getAttentionFocusPoint(from: buffer) ?? .zero
            let boundingBoxes = self.getBoundingBoxes(buffer: buffer, saliencyType: .objectness)
            
            guard let boundingBoxes else {
                logger.debug("No bounding boxes found, resetting guidance system")
                resetTrackerAndGuidance()
                return nil
            }

            let boundingBox = boundingBoxes.filter({ $0.contains(focusPoint) })
            let trackedObjectCandidate: CGRect = boundingBox.first ?? .zero
            
            if trackedObjectCandidate.width > 0 && trackedObjectCandidate.height > 0 {
                if trackedObjectCandidate.width > 0.33 || trackedObjectCandidate.height > 0.33 {
                    self.trackedObjects = [VNDetectedObjectObservation(boundingBox: trackedObjectCandidate)]
                }
            }
            
            let origin = CGPoint(
                x: focusPoint.x - 0.2,
                y: focusPoint.y - 0.2
            )
            self.trackedObjects = [VNDetectedObjectObservation(boundingBox: CGRect(origin: origin, size: CGSize(width: 0.4, height: 0.4)))]
            self.shouldReset = false
        }
        
        
        guard let mainObject = self.trackedObjects?.first else {
            logger.debug("No main object detected, resetting guidance system")
            resetTrackerAndGuidance()
            return nil
        }
        
        // MARK: DETERMINE KEYPOINT
        let width = mainObject.boundingBox.width
        let height = mainObject.boundingBox.height
        let centerX = mainObject.boundingBox.midX
        let centerY = mainObject.boundingBox.midY
            
        // Tall Object
        if height > 0.33 || (height > 0.33 && width > 0.33 && height >= width) {
            let leftDistance = distanceBetween(CGPoint(x: centerX, y: 0), and: self.keypoints[0])
            let rightDistance = distanceBetween(CGPoint(x: centerX, y: 0), and: self.keypoints[1])
            
            if rightDistance > leftDistance {
                print("tall left")
                self.targetPoint = CGPoint(x: 0.33, y: 0.5)
                self.selectedKeypoints.append(0)
                self.selectedKeypoints.append(2)
            }
            else {
                print("tall right")
                self.targetPoint = CGPoint(x: 0.67, y: 0.5)
                self.selectedKeypoints.append(1)
                self.selectedKeypoints.append(3)
            }
        }
        
        // Wide Object
        else if width > 0.33 || (height > 0.33 && width > 0.33 && height < width) {
            let upperVerticalLineDistance = distanceBetween(CGPoint(x: 0, y: centerY), and: self.keypoints[0])
            let lowerVerticalLineDistance = distanceBetween(CGPoint(x: 0, y: centerY), and: self.keypoints[2])

            if upperVerticalLineDistance > lowerVerticalLineDistance {
                print("wide below")
                self.targetPoint = CGPoint(x: 0.5, y: 0.67)
                self.selectedKeypoints.append(2)
                self.selectedKeypoints.append(3)
            }
            else {
                print("wide above")
                self.targetPoint = CGPoint(x: 0.5, y: 0.33)
                self.selectedKeypoints.append(0)
                self.selectedKeypoints.append(1)
            }
        }
        
        // Small Object
        else {
            print("small")
            let distance = keypoints.map({distanceBetween($0, and: CGPoint(x: mainObject.boundingBox.midX, y: mainObject.boundingBox.midY))})
            guard let selectedKeyPoint = distance.firstIndex(of: distance.min()!) else { return nil }

            self.targetPoint = keypoints[selectedKeyPoint]
            self.selectedKeypoints.append(selectedKeyPoint)
        }
        
        // MARK: OBJECT TRACKING
        guard let trackResult = self.startTrackingObject(buffer: buffer, initialObservation: mainObject) else {
            logger.debug("Can't track object")
            resetTrackerAndGuidance()
            return nil
        }
        
        self.trackedObjects?.removeAll()
        self.trackedObjects?.append(trackResult)
        
        // reset tracked object coordinate
        let trackedObjectBoundingBox = self.trackedObjects?.first?.boundingBox
        let adjustmentNeededX = -(targetPoint.x - (trackedObjectBoundingBox?.midX ?? 0))
        let adjustmentNeededY = -(targetPoint.y - (trackedObjectBoundingBox?.midY ?? 0))
        
        print(trackedObjectBoundingBox?.origin.y ?? 0 + adjustmentNeededY)
        
        return CGPoint(
            x: (trackedObjectBoundingBox?.origin.x ?? 0) + adjustmentNeededX,
            y: 1 - (trackedObjectBoundingBox?.origin.y ?? 0) - adjustmentNeededY
        )
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
    
    func startTrackingObject(buffer: CVPixelBuffer, initialObservation: VNDetectedObjectObservation) -> VNDetectedObjectObservation? {
        if self.tracker == nil {
            self.tracker = VNTrackObjectRequest(detectedObjectObservation: initialObservation)
            self.tracker?.trackingLevel = .accurate
        }
        
        guard let tracker = self.tracker else {
            logger.debug("No tracker available.")
            resetTrackerAndGuidance()
            return nil
        }
        
        // create new tracker
        let sequenceHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: saliencyHandler.imageOrientationFromDeviceOrientation(), options: [:])

        // Track the object in subsequent frames
        do {
            // Pass the frame and request to the handler
            try sequenceHandler.perform([tracker])
            
            // Check the results after performing the request
            if let result = tracker.results?.first as? VNDetectedObjectObservation {
                if result.confidence > 0.33 {  // Adjust confidence threshold as needed
                    self.shouldReset = false
                    return result
                } else {
                    resetTrackerAndGuidance()
                    logger.debug("Tracking lost with low confidence")
                    return nil
                }
            }
        } catch {
            logger.debug("Tracking error: \(error)")
            resetTrackerAndGuidance()
            return nil
        }
        
        logger.debug("Tracking error: No result")
        resetTrackerAndGuidance()
        return nil
    }
    
    func getAttentionFocusPoint(from buffer: CVPixelBuffer) -> CGPoint? {
        guard let observation = saliencyHandler.detectSalientRegions(in: buffer, saliencyType: .attention, frameType: .ruleOfThirds) else {
            logger.debug("Saliency result yield no result")
            resetTrackerAndGuidance()
            return nil
        }
        
        
        var focusPoint: CGPoint? = .zero
        if let heatmapCGImage = saliencyHandler.convertPixelBufferToCGImage(observation.pixelBuffer),
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
        
        return rect.contains(point)
    }
}
