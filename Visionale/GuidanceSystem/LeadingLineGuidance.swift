//
//  LeadingLineGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 29/10/24.
//

import Vision

@Observable
class LeadingLineGuidance: GuidanceSystem {
    var contourRect: [CGRect] = []
    
    var trackingRequests: [VNTrackObjectRequest]? = nil
    var sequenceRequestHandler: VNSequenceRequestHandler = VNSequenceRequestHandler()
    var saliencyHandler: SaliencyHandler = .init()
    var contourHandler: ContourDetectionHandler = .init()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var selectedKeypoints: [Int] = []
    var keypoints: [CGPoint] = [
        CGPoint(x: 0.33, y: 0.33),
        CGPoint(x: 0.67, y: 0.33),
        CGPoint(x: 0.5, y: 0.5),
        CGPoint(x: 0.33, y: 0.67),
        CGPoint(x: 0.67, y: 0.67),
    ]
    var targetPoint: CGPoint = .zero
    
    var trackedObjects: [CGRect]? = []
    
    var contourPaths: [StraightLine] = []
    var paths: CGPath = .init(rect: .zero, transform: .none)
    
    func guide(buffer: CMSampleBuffer) {
        guard let cvPixelBuffer = contourHandler.convertPixelBuffer(buffer: buffer) else { return }
        
        self.bestShotPoint = self.findBestShotPoint(buffer: cvPixelBuffer)
        self.isAligned = self.checkAlignment(shotPoint: self.bestShotPoint ?? .zero)
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
        var vanishingPointBoundingBox: CGRect = self.trackedObjects?.first ?? .zero
        
        if shouldReset {
            self.trackedObjects?.removeAll()
            self.selectedKeypoints.removeAll()
            
            guard let contours = contourHandler.detectContour(in: buffer) else {
                logger.debug("No contour detected")
                reset()
                return nil
            }
            self.paths = contours.normalizedPath
            self.contourPaths = self.extractStraightLines(from: contours.normalizedPath)
            
            guard let vanishingPoint = self.findVanishingPoint() else {
                logger.debug("No vanishing point detected")
                reset()
                return nil
            }
            vanishingPointBoundingBox = CGRect(x: vanishingPoint.x - 0.125, y: vanishingPoint.y - 0.125, width: 0.25, height: 0.25)
            self.trackingRequests = [VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation(boundingBox: vanishingPointBoundingBox))]
            self.sequenceRequestHandler = VNSequenceRequestHandler()
            
            self.shouldReset = false
        }
        
        if selectedKeypoints.isEmpty == false {
            let mainObject = self.trackedObjects?.first
            guard let mainObject else { return nil }
            
            if mainObject.midX < 0.4 || mainObject.midX > 0.6 || mainObject.midY < 0.4 || mainObject.midY > 0.6 {
                let distance = keypoints.map({distanceBetween($0, and: CGPoint(x: mainObject.midX, y: mainObject.midY))})
                guard let selectedKeyPoint = distance.firstIndex(of: distance.min()!) else { return nil }

                self.targetPoint = keypoints[selectedKeyPoint]
                self.selectedKeypoints.append(selectedKeyPoint)
            }
        }
        else {
            let distance = keypoints.map({distanceBetween($0, and: CGPoint(x: vanishingPointBoundingBox.midX, y: vanishingPointBoundingBox.midY))})
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
        let adjustmentNeededX = -(targetPoint.x - trackedObjectBoundingBox.midX)
        let adjustmentNeededY = -(targetPoint.y - trackedObjectBoundingBox.midY)
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
        let min = 0.5 * 0.9
        let max = 0.5 * 1.1
        
        if shotPoint.x > min && shotPoint.x < max && shotPoint.y > min && shotPoint.y < max {
            return true
        }
        else {
            return false
        }
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
    
    func distanceBetween(_ point: CGPoint, and otherPoint: CGPoint) -> CGFloat {
        let dx = otherPoint.x - point.x
        let dy = otherPoint.y - point.y
        
        return sqrt(dx * dx + dy * dy)
    }

    func reset() {
        self.trackingRequests = nil
        self.shouldReset = true
        self.isAligned = false
        self.shouldReset = true
        self.selectedKeypoints.removeAll()
        self.bestShotPoint = .zero
    }
    
    func extractStraightLines(from path: CGPath) -> [StraightLine] {
        var subpaths = [StraightLine]() // Array to store subpaths
        var currentPoint = CGPoint.zero // Track the current point
        var startPoint = CGPoint.zero
        var currentDirection: LineDirection = .unknown

        // Traverse through detected path
        path.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint:
                startPoint = element.pointee.points[0]
                currentPoint = startPoint
                currentDirection = .unknown
            case .addLineToPoint:
                var direction: LineDirection = .unknown
                let point = element.pointee.points[0]
                let distanceFromPrevPoint = hypot(point.x - currentPoint.x, point.y - currentPoint.y)
                
                // if current point is far enough from previous point
                if distanceFromPrevPoint > 0.02 {
                    if currentPoint != .zero {
                        if point.x >= currentPoint.x && point.y < currentPoint.y {
                            direction = .downRight
                        }
                        else if point.x < currentPoint.x && point.y < currentPoint.y {
                            direction = .downLeft
                        }
                        else if point.x >= currentPoint.x && point.y >= currentPoint.y {
                            direction = .upRight
                        }
                        else if point.x < currentPoint.x && point.y >= currentPoint.y {
                            direction = .upLeft
                        }
                        else {
                            direction = .unknown
                        }
                    }
                    
                    // detect direction change
                    if direction != currentDirection && currentPoint != .zero {
                        subpaths.append(StraightLine(start: startPoint, end: point))
                        startPoint = point
                        currentDirection = direction
                    }
                    
                    currentPoint = point
                }
                
            case .closeSubpath:
                currentDirection = .unknown
                subpaths.append(StraightLine(start: startPoint, end: currentPoint))
            case .addQuadCurveToPoint, .addCurveToPoint:
                break
            @unknown default:
                fatalError("Unexpected element type in CGPath.")
            }
        }
        
        subpaths = subpaths.filter({ path in
            let distance = hypot(path.end.x - path.start.x, path.end.y - path.start.y)
            
            return distance > 0.33
        })
        return subpaths
    }


    func intersection(of line1: StraightLine, and line2: StraightLine) -> CGPoint? {
        let x1 = line1.start.x
        let y1 = line1.start.y
        let x2 = line1.end.x
        let y2 = line1.end.y
        
        let x3 = line2.start.x
        let y3 = line2.start.y
        let x4 = line2.end.x
        let y4 = line2.end.y
        
        let m1 = (y2 - y1) / (x2 - x1)
        let m2 = (y4 - y3) / (x4 - x3)
        
        if m1 == m2 {
            logger.debug("Parallel lines")
            return nil
        }
        
        let c1 = y1 - m1 * x1
        let c2 = y3 - m2 * x3
        
        let x = (c2 - c1) / (m1 - m2)
        let y = m1 * x + c1
        
        return CGPoint(x: x, y: 1 - y)
    }

    func findVanishingPoint() -> CGPoint? {
        let lines = self.contourPaths
        var intersectionPoints: [CGPoint] = []
        
        // Calculate intersections for each unique pair of lines
        for i in 0..<lines.count {
            for j in (i + 1)..<lines.count {
                if let intersect = intersection(of: lines[i], and: lines[j]) {
                    intersectionPoints.append(intersect)
                }
            }
        }
        
        // Calculate the average point as a simple vanishing point approximation
        guard !intersectionPoints.isEmpty else { return nil }
        
        let sum = intersectionPoints.reduce(CGPoint.zero) { (sum, point) in
            CGPoint(x: sum.x + point.x, y: sum.y + point.y)
        }
        
        let averagePoint = CGPoint(x: sum.x / CGFloat(intersectionPoints.count), y: sum.y / CGFloat(intersectionPoints.count))
        return averagePoint
        
    }
    
    func getBoundingBoxes(buffer: CVPixelBuffer, saliencyType: SaliencyType) -> [CGRect]? {
        return nil
    }
}
