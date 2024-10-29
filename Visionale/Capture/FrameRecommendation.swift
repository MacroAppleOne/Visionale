//
//  FrameRecommendation.swift
//  Visionalé
//
//  Created by Nico Samuelson on 25/10/24.
//

import CoreML
import CoreImage
import AVFoundation

class FrameRecommendation {
    let model: FrameRecom3C?
    
    init() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndNeuralEngine
//            self.model = try CompositionClassifier(configuration: config)
            self.model = try FrameRecom3C(configuration: config)
        } catch {
            print("Error initializing model: \(error)")
            self.model = nil
        }
    }
    
    // Function to resize a pixel buffer
    func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer, targetSize: CGSize) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        let scale = CGAffineTransform(scaleX: targetSize.width / ciImage.extent.width, y: targetSize.height / ciImage.extent.height)
        let resizedImage = ciImage.transformed(by: scale)
        
        var resizedPixelBuffer: CVPixelBuffer?
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
                  kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!]
        CVPixelBufferCreate(kCFAllocatorDefault, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32BGRA, attributes as CFDictionary, &resizedPixelBuffer)
        context.render(resizedImage, to: resizedPixelBuffer!)
        
        return resizedPixelBuffer
    }
    
    // Function to convert a resized pixel buffer to MLMultiArray
    func pixelBufferToMultiArray(_ pixelBuffer: CVPixelBuffer) -> MLMultiArray? {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
            return nil
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        // Create the MLMultiArray with shape (1, 224, 224, 3)
        guard let multiArray = try? MLMultiArray(shape: [1, 224, 224, 3] as [NSNumber], dataType: .float32) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
            return nil
        }
        
        let ptr = baseAddress.assumingMemoryBound(to: UInt8.self)
        var index = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let r = Float(ptr[y * bytesPerRow + x * 4 + 0]) / 255.0  // Red channel
                let g = Float(ptr[y * bytesPerRow + x * 4 + 1]) / 255.0  // Green channel
                let b = Float(ptr[y * bytesPerRow + x * 4 + 2]) / 255.0  // Blue channel
                
                // Assign normalized values to the MultiArray
                multiArray[[0, 0, NSNumber(value: y), NSNumber(value: x)]] = NSNumber(value: r)
                multiArray[[0, 1, NSNumber(value: y), NSNumber(value: x)]] = NSNumber(value: g)
                multiArray[[0, 2, NSNumber(value: y), NSNumber(value: x)]] = NSNumber(value: b)
                
                index += 1
            }
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        return multiArray
    }
    
    func convertPredictionIntoLabel(in multiArray: MLMultiArray?) -> String? {
        guard let multiArray = multiArray else { return nil }
        
        var maxValue: Double = 0.0
        var maxIndex: Int = 0
        for i in 0..<multiArray.count {
            if let currentValue = multiArray[i] as? Double, currentValue > maxValue {
                maxValue = currentValue
                maxIndex = i
            }
        }
        
        // Access the pointer to the underlying data
//        let pointer = multiArray.dataPointer.bindMemory(to: Double.self, capacity: multiArray.count)
        
        // Create an array from the pointer
//        let array = Array(UnsafeBufferPointer(start: pointer, count: multiArray.count))
        
//        print(array)
        
        // Create an array of tuples (index, value) and sort by value in descending order
//        let indexedArray = array.enumerated().sorted(by: { $0.element > $1.element })

        // Extract the indices of the top 3 elements
//        let topThreeIndices = indexedArray.prefix(3).map { $0.offset }
        
//        let classes = ["center", "curved", "golden_ratio", "leading_line", "rule_of_thirds", "symmetric"]
        let classes = ["center", "curved", "rule of thirds"]
//        let classes = ["curved", "rule_of_thirds", "leading_line", "center", "golden_ratio", "symmetric"]
        
//        print(topThreeIndices)
        
        return classes[maxIndex]
        
//        return Array(arrayLiteral: classes[topThreeIndices[0]], classes[topThreeIndices[1]], classes[topThreeIndices[2]])
    }
    
    func processFrame(_ buffer: CMSampleBuffer) -> String {
        var predicted: String = "Unknwon"
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            logger.debug("Error getting pixel buffer")
            return predicted
        }
        
        // Resize and process the pixel buffer
        guard let resizedBuffer = self.resizePixelBuffer(pixelBuffer, targetSize: CGSize(width: 224, height: 224)) else {
            print("Error resizing pixel buffer")
            logger.debug("Error resizing pixel buffer")
            return predicted
        }
        
        // Convert to MLMultiArray
        if let multiArray = self.pixelBufferToMultiArray(resizedBuffer) {
            // Pass the MLMultiArray to your Core ML model
            do {
                let input = FrameRecom3CInput(input_12: multiArray)  // Ensure your model's input type matches
                let prediction = try model?.prediction(input: input)
                
                predicted = convertPredictionIntoLabel(in: prediction?.Identity) ?? "Unknown"
                
            } catch {
                logger.debug("Error making prediction: \(error)")
            }
        }
        
        return predicted
    }
}
