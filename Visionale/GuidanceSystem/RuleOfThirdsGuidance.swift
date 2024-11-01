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
    private var trackingRequests: [VNTrackObjectRequest]?
    private var sequenceRequestHandler = VNSequenceRequestHandler()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var trackedObjects: [CGRect]? = []
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
    
    func reset() {
        self.trackingRequests = nil
        self.shouldReset = true
        self.isAligned = false
        self.shouldReset = true
        self.selectedKeypoints.removeAll()
        self.targetPoint = .zero
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
        var mainObject: CGRect = .zero
        
        // MARK: SALIENCY
        if shouldReset {
            self.trackedObjects?.removeAll()
            self.selectedKeypoints.removeAll()
            
            let focusPoint = self.getAttentionFocusPoint(from: buffer) ?? .zero
            let boundingBoxes = self.getBoundingBoxes(buffer: buffer, saliencyType: .objectness)
            
            guard let boundingBoxes else {
                logger.debug("No bounding boxes found, resetting guidance system")
                reset()
                return nil
            }

            let boundingBox = boundingBoxes.filter({ $0.contains(focusPoint) })
            let trackedObjectCandidate: CGRect = boundingBox.first ?? .zero
            
            if trackedObjectCandidate.width > 0 && trackedObjectCandidate.height > 0 {
                if trackedObjectCandidate.width > 0.33 || trackedObjectCandidate.height > 0.33 {
                    self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: trackedObjectCandidate))]
                    self.sequenceRequestHandler = VNSequenceRequestHandler()
                    mainObject = trackedObjectCandidate
                }
                else {
                    let origin = CGPoint(
                        x: focusPoint.x - 0.2,
                        y: focusPoint.y - 0.2
                    )
                    let rect = CGRect(origin: origin, size: CGSize(width: 0.4, height: 0.4))
                    self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: rect))]
                    self.sequenceRequestHandler = VNSequenceRequestHandler()
                    mainObject = rect
                }
                self.shouldReset = false
            }
            else if !boundingBoxes.isEmpty {
                let origin = CGPoint(
                    x: focusPoint.x - 0.2,
                    y: focusPoint.y - 0.2
                )
                let rect = CGRect(origin: origin, size: CGSize(width: 0.4, height: 0.4))
                self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: rect))]
                self.sequenceRequestHandler = VNSequenceRequestHandler()
                mainObject = rect
                self.shouldReset = false
            }
            else {
                reset()
            }
        }
        
        // MARK: DETERMINE KEYPOINT
        let width = mainObject.width
        let height = mainObject.height
        let centerX = mainObject.midX
        let centerY = mainObject.midY
            
        // Tall Object
        if height > 0.33 || (height > 0.33 && width > 0.33 && height >= width) {
            let leftDistance = distanceBetween(CGPoint(x: centerX, y: 0), and: self.keypoints[0])
            let rightDistance = distanceBetween(CGPoint(x: centerX, y: 0), and: self.keypoints[1])
            
            if rightDistance > leftDistance {
                self.targetPoint = CGPoint(x: 0.33, y: 0.5)
                self.selectedKeypoints.append(0)
                self.selectedKeypoints.append(2)
            }
            else {
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
                self.targetPoint = CGPoint(x: 0.5, y: 0.67)
                self.selectedKeypoints.append(2)
                self.selectedKeypoints.append(3)
            }
            else {
                self.targetPoint = CGPoint(x: 0.5, y: 0.33)
                self.selectedKeypoints.append(0)
                self.selectedKeypoints.append(1)
            }
        }
        
        // Small Object
        else {
            let distance = keypoints.map({distanceBetween($0, and: CGPoint(x: mainObject.midX, y: mainObject.midY))})
            guard let selectedKeyPoint = distance.firstIndex(of: distance.min()!) else { return nil }

            self.targetPoint = keypoints[selectedKeyPoint]
            self.selectedKeypoints.append(selectedKeyPoint)
        }
        
        // MARK: OBJECT TRACKING
        guard let trackResult = self.startTrackingObject(buffer: buffer) else {
            logger.debug("Can't get object tracking result")
            return nil
        }
        
        self.trackedObjects = [trackResult.boundingBox]
        
        // reset tracked object coordinate
        let trackedObjectBoundingBox = trackResult.boundingBox
        let adjustmentNeededX = -(targetPoint.x - (trackedObjectBoundingBox.midX))
        let adjustmentNeededY = -(targetPoint.y - (trackedObjectBoundingBox.midY))
        
        return CGPoint(
            x: trackedObjectBoundingBox.midX + adjustmentNeededX,
            y: 1 - (trackedObjectBoundingBox.midY + adjustmentNeededY)
        )
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
    
    func getAttentionFocusPoint(from buffer: CVPixelBuffer) -> CGPoint? {
        guard let observation = saliencyHandler.detectSalientRegions(in: buffer, saliencyType: .attention, frameType: .ruleOfThirds) else {
            logger.debug("Saliency result yield no result")
            reset()
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
            logger.debug("Failed to get image data.")
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
}
