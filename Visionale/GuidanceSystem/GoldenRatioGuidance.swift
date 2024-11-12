//
//  GoldenRatioGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 29/10/24.
//

import Vision
import UIKit

@Observable
class GoldenRatioGuidance: GuidanceSystem {
    var contourRect: [CGRect] = []
    
    var saliencyHandler: SaliencyHandler = .init()
    var trackingRequests: [VNTrackObjectRequest]?
    var sequenceRequestHandler = VNSequenceRequestHandler()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var trackedObjects: [CGRect]? = []
    var selectedKeypoints: [Int] = []
    var targetPoint: CGPoint? = .zero
    var keypoints: [CGPoint] = []
    var contourPaths: [StraightLine] = []
    var paths: CGPath = .init(rect: .zero, transform: .none)
    
    var aspectRatio: CGFloat = 0
    var orientation: GoldenRatioOrientation = .bottomLeft
    
    init(aspectRatio: CGFloat, orientation: GoldenRatioOrientation) {
        self.aspectRatio = aspectRatio
        self.orientation = orientation
    }
    
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
        self.bestShotPoint = .zero
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
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
                    self.trackedObjects = [trackedObjectCandidate]
                }
                else {
                    let origin = CGPoint(
                        x: focusPoint.x - 0.2,
                        y: focusPoint.y - 0.2
                    )
                    let rect = CGRect(origin: origin, size: CGSize(width: 0.4, height: 0.4))
                    self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: rect))]
                    self.sequenceRequestHandler = VNSequenceRequestHandler()
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
                self.shouldReset = false
            }
            else {
                reset()
            }
        }
        
        let offsetX = self.aspectRatio == 9 / 16 ? 0 : 0.214
        
        switch orientation {
        case .bottomLeft:
            self.targetPoint = CGPoint(
                x: (offsetX / 2) + 0.236,
                y: 0.282
            )
        case .bottomRight:
            self.targetPoint = CGPoint(
                x: 1 - ((offsetX / 2) + 0.236),
                y: 0.282
            )
        case .topLeft:
            self.targetPoint = CGPoint(
                x: (offsetX / 2) + 0.236,
                y: 1 - 0.282
            )
        case .topRight:
            self.targetPoint = CGPoint(
                x: 1 - ((offsetX / 2) + 0.236),
                y: 1 - 0.282
            )
        }
        
        // MARK: OBJECT TRACKING
        guard let trackResult = self.startTrackingObject(buffer: buffer) else {
            logger.debug("Can't get object tracking result")
            reset()
            return nil
        }
        
        self.trackedObjects = [trackResult.boundingBox]
        
        let trackedObjectBoundingBox = trackResult.boundingBox
        let adjustmentNeededX = -((targetPoint?.x ?? 0) - trackedObjectBoundingBox.midX)
        let adjustmentNeededY = -((targetPoint?.y ?? 0) - trackedObjectBoundingBox.midY)
        let newShotPoint = CGPoint(
            x: 0.5 + adjustmentNeededX,
            y: 1 - (0.5 + adjustmentNeededY)
        )
        
        if isAligned {
            if abs(newShotPoint.x - (self.bestShotPoint?.x ?? 0)) > 0.1 || abs(newShotPoint.y - (self.bestShotPoint?.y ?? 0)) > 0.1 {
                return newShotPoint
            }
            else {
                return CGPoint(x: 0.5, y: 0.5)
            }
        }
        else {
            if abs(newShotPoint.x - (self.bestShotPoint?.x ?? 0)) > 0.025 || abs(newShotPoint.y - (self.bestShotPoint?.y ?? 0)) > 0.025 {
                return newShotPoint
            }
            else {
                return self.bestShotPoint
            }
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
}
