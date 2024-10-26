//
//  MachineLearning.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 10/10/24.
//

import CoreML
import CoreImage
import AVFoundation

/// A class responsible for handling machine learning classification tasks.
@Observable
final class MachineLearningClassificationLayer: NSObject, ObservableObject {
    var predictionLabel: String?
    /// The CoreML model used for image classification.
    let model: ImageClassificationModel?
    private var lastProcessingTime: Date = Date(timeIntervalSince1970: 0)
    override init() {
        do {
            self.model = try ImageClassificationModel(configuration:.init())
        }
        catch {
            print("Error loading model: \(error)")
            self.model = nil
        }
        
        super.init()
    }
    
    func processFrame(_ image: MLMultiArray) {
        do {
            let input = ImageClassificationModelInput(x_1: image)
            let prediction = try model?.prediction(input: input)
            
            // Update the prediction label which will notify the UI via @Published
            DispatchQueue.main.async {
                self.predictionLabel = self.convertPredictionIntoLabel(in: prediction?.var_1120)
            }
        } catch {
            print("Error making prediction: \(error)")
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
        
        // Create the MLMultiArray with shape (1, 3, 256, 256)
        guard let multiArray = try? MLMultiArray(shape: [1, 3, 256, 256] as [NSNumber], dataType: .float32) else {
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
        
        // Access the pointer to the underlying data
        let pointer = multiArray.dataPointer.bindMemory(to: Double.self, capacity: multiArray.count)
        
        // Create an array from the pointer
        let array = Array(UnsafeBufferPointer(start: pointer, count: multiArray.count))
        
        // Create an array of tuples (index, value) and sort by value in descending order
        let indexedArray = array.enumerated().sorted(by: { $0.element > $1.element })
        
        let classes = ["center", "curved", "diagonal", "golden_ratio", "rule_of_thirds", "symmetric", "triangle"]
        
        return classes[indexedArray.first!.offset]
    }
    
}

// MARK: - ML
extension MachineLearningClassificationLayer: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Get current time
        let currentTime = Date()

        // Check if at least 1 second has passed since last processing
        if currentTime.timeIntervalSince(lastProcessingTime) < 0.5 {
            // Less than 0.5 second has passed, skip processing
            return
        }

        // Update last processing time
        lastProcessingTime = currentTime

        // Proceed with processing
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Resize and process the pixel buffer
        guard let resizedBuffer = self.resizePixelBuffer(pixelBuffer, targetSize: CGSize(width: 256, height: 256)) else { return }

        // Convert to MLMultiArray
        if let multiArray = self.pixelBufferToMultiArray(resizedBuffer) {
            // Pass the MLMultiArray to your Core ML model
            self.processFrame(multiArray)
        }
    }
}
