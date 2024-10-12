import Vision
import UIKit


class GuidanceSystem {
    func convertBufferIntoCIImage(buffer: CMSampleBuffer) -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            logger.debug("Could not get image buffer from CMSampleBuffer")
            return nil
        }
        
        // Create a CIImage from the CVPixelBuffer
        return CIImage(cvPixelBuffer: pixelBuffer)
    }
    
    func detectSalientRegions(in image: CIImage, saliencyType: SaliencyType = .objectness, frameType: FrameType, completion: @escaping ([VNRectangleObservation]?) -> Void) {
        // Create a CIContext (can be reused if needed)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            logger.debug("Could not create CGImage from CIImage")
            completion(nil)
            return
        }
        
        // Create the appropriate VNRequest for the saliency type
        let request: VNImageBasedRequest = (saliencyType == .attention) ? VNGenerateAttentionBasedSaliencyImageRequest() : VNGenerateObjectnessBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
//        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
                // Check if the request result contains a VNSaliencyImageObservation
                guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                    logger.debug("Could not get saliency result")
                    completion(nil)
                    return
                }
                
                if saliencyType == .objectness {
                    completion(observation.salientObjects ?? nil)
                }
                else if saliencyType == .attention {
                    if let firstSalientObject = observation.salientObjects?.first {
//                        DispatchQueue.main.async {
                            completion([firstSalientObject])
//                        }
                    } else {
//                        DispatchQueue.main.async {
                            logger.debug("No salient object detected")
                            completion(nil)
//                        }
                    }
                }
            } catch {
                logger.debug("Error processing saliency: \(error)")
                completion(nil)
            }
//        }
    }
    
    func determineBestShotPoint(image: CIImage, rect: [VNRectangleObservation]?, frameType: FrameType) -> CGPoint? {
        guard let rect = rect else {
            logger.debug("No salient objects found")
            return nil
        }
        
        var bestShotPoint: CGPoint = .zero
        
        if frameType == .center {
            bestShotPoint = CGPoint(x: rect.first?.boundingBox.midX ?? 0.0, y: rect.first?.boundingBox.midY ?? 0.0)
        }
        else if frameType == .ruleOfThirds {
            
        }
        else if frameType == .goldenRatio {
            
        }
        else if frameType == .symmetric {
            
        }
        else if frameType == .diagonal {
            
        }
        
        print("best shot point: \(bestShotPoint)")
        return bestShotPoint
    }
    
    func doShotSuggestion(buffer: CMSampleBuffer, frameType: FrameType) -> CGPoint? {
        guard let ciImage = convertBufferIntoCIImage(buffer: buffer) else { return nil }
        
        var bestPoint: CGPoint?
        self.detectSalientRegions(in: ciImage, frameType: .center, completion: { result in
            bestPoint = self.determineBestShotPoint(image: ciImage, rect: result, frameType: frameType)
            print(bestPoint)
        })
        
        return bestPoint
    }
}

