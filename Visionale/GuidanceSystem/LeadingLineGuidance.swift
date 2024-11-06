//
//  LeadingLineGuidance.swift
//  Visionalé
//
//  Created by Nico Samuelson on 29/10/24.
//

import Vision
//import CoreML

struct StraightLine: Equatable, Identifiable{
    let id: UUID = UUID()
    let start: CGPoint
    let end: CGPoint
    
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
}

@Observable
class LeadingLineGuidance: GuidanceSystem {
    var trackingRequests: [VNTrackObjectRequest]? = nil
    var sequenceRequestHandler: VNSequenceRequestHandler = VNSequenceRequestHandler()
    var saliencyHandler: SaliencyHandler = .init()
    var contourHandler: ContourHandler = .init()
    
    var bestShotPoint: CGPoint? = .zero
    
    var isAligned: Bool = false
    var shouldReset: Bool = true
    
    var selectedKeypoints: [Int] = []
    var keypoints: [CGPoint] = []
    var trackedObjects: [CGRect]? = []
    var contourPaths: [StraightLine] = []
    var paths: CGPath = .init(rect: .zero, transform: .none)
    
    func guide(buffer: CMSampleBuffer) {
        guard let cvPixelBuffer = contourHandler.convertPixelBuffer(buffer: buffer) else { return }
        
        self.bestShotPoint = self.findBestShotPoint(buffer: cvPixelBuffer)
    }
    
    func findBestShotPoint(buffer: CVPixelBuffer) -> CGPoint? {
        let contours = contourHandler.detectContour(in: buffer)
        
        let paths = contours.map { contour -> CGPath in
            return contour.normalizedPath
        }
        
        self.contourPaths = self.extractLines(from: paths ?? .init(rect: .zero, transform: .none))
        self.paths = paths ?? .init(rect: .zero, transform: .none)
        
        return nil
    }
    
    func checkAlignment(shotPoint: CGPoint) -> Bool {
        return false
    }
    
    func getBoundingBoxes(buffer: CVPixelBuffer, saliencyType: SaliencyType) -> [CGRect]? {
        return nil
    }
    
    func startTrackingObject(buffer: CVPixelBuffer) -> VNDetectedObjectObservation? {
        return nil
    }

    func reset() {
        
    }

    func extractLines(from path: CGPath) -> [StraightLine] {
        var lines: [StraightLine] = []
        var currentPoint = CGPoint.zero
        let minLength: CGFloat = 0.0035
        
        path.applyWithBlock { element in
            let points = element.pointee.points
            switch element.pointee.type {
            case .moveToPoint:
                currentPoint = points[0]
            case .addLineToPoint:
                let lineEnd = points[0]
                let length = hypot(lineEnd.x - currentPoint.x, lineEnd.y - currentPoint.y)
                
                if length >= minLength {
                    lines.append(StraightLine(start: currentPoint, end: lineEnd))
                }
                
                currentPoint = lineEnd
            default:
                break
            }
        }
        return lines
    }
    
//    func extractLines(from path: CGPath) -> [StraightLine] {
//        var subpaths = [StraightLine]() // Array to store subpaths
//        var currentSubpath = [StraightLine]() // Current subpath being processed
//        var currentPoint = CGPoint.zero // Track the current point
//
//        // Path Applier Function
//        path.applyWithBlock { element in
//            switch element.pointee.type {
//            case .moveToPoint:
//                // Start a new subpath, store the existing subpath if it's not empty
//                if !currentSubpath.isEmpty {
//                    subpaths.append(contentsOf: currentSubpath)
//                    currentSubpath = [] // Reset current subpath
//                }
//                // Update the current point for a "move"
//                currentPoint = element.pointee.points[0]
//            case .addLineToPoint:
//                // Get the end point of the line segment
//                let endPoint = element.pointee.points[0]
//                // Create and add the line segment to the current subpath
//                let straightLine = StraightLine(start: currentPoint, end: endPoint)
//                currentSubpath.append(straightLine)
//                // Update current point
//                currentPoint = endPoint
//            case .closeSubpath:
//                // If we encounter a close subpath, save the current subpath
//                if !currentSubpath.isEmpty {
//                    subpaths.append(contentsOf: currentSubpath)
//                    currentSubpath = [] // Reset for the next subpath
//                }
//            case .addQuadCurveToPoint, .addCurveToPoint:
//                // Handle other elements as needed (e.g., curves)
//                break
//            @unknown default:
//                fatalError("Unexpected element type in CGPath.")
//            }
//        }
//
//        // Add any remaining subpath
//        if !currentSubpath.isEmpty {
//            let start = currentSubpath[0].start
//            let end = currentSubpath[currentSubpath.count-1].end
//            let straightLine = StraightLine(start: start, end: end)
//            let length = hypot(end.x - start.x, end.y - start.y)
//            
//            if length >= 0.4 {
//                subpaths.append(straightLine)
//            }
//        }
//
//        return subpaths
//    }


    func intersection(of line1: StraightLine, and line2: StraightLine) -> CGPoint? {
        let p1 = line1.start
        let p2 = line1.end
        let p3 = line2.start
        let p4 = line2.end
//        let (p1, p2) = line1.
//        let (p3, p4) = line2
        
        let denominator = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
        guard denominator != 0 else { return nil } // Parallel lines
        
        let xNumerator = (p1.x * p2.y - p1.y * p2.x) * (p3.x - p4.x) - (p1.x - p2.x) * (p3.x * p4.y - p3.y * p4.x)
        let yNumerator = (p1.x * p2.y - p1.y * p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x * p4.x - p3.y * p4.x)
        
        let x = xNumerator / denominator
        let y = yNumerator / denominator
        
        return CGPoint(x: x, y: y)
    }

    func findVanishingPoint(from path: CGPath) -> CGPoint? {
        let lines = extractLines(from: path)
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
}
