import Foundation
import UIKit
import SwiftUI

final class CompositionViewModel: ObservableObject {
    @Published var mlcLayer: MachineLearningClassificationLayer
    @Published var activeID: UUID
    @Published var activeComposition: String = "Center"
    
    var compositions: [Composition] = [
        Composition(name: "CENTER", description: "", image: "center_default", isRecommended: false, imageRecommended: "center_default_recommend", imageSelected: "center_selected", imageSelectedRecommended: "center_selected_recommend"),
        Composition(name: "CURVED", description: "", image: "curved_default", isRecommended: false, imageRecommended: "curved_default_recommend", imageSelected: "curved_selected", imageSelectedRecommended: "curved_selected_recommend"),
        Composition(name: "DIAGONAL", description: "", image: "diagonal_default", isRecommended: false, imageRecommended: "diagonal_default_recommend", imageSelected: "diagonal_selected", imageSelectedRecommended: "diagonal_selected_recommend"),
        Composition(name: "GOLDEN RATIO", description: "", image: "golden_default", isRecommended: false, imageRecommended: "golden_default_recommend", imageSelected: "golden_selected", imageSelectedRecommended: "golden_selected_recommend"),
        Composition(name: "RULE OF THIRDS", description: "", image: "rot_default", isRecommended: false, imageRecommended: "rot_default_recommend", imageSelected: "rot_selected", imageSelectedRecommended: "rot_selected_recommend"),
        Composition(name: "SYMMETRIC", description: "", image: "symmetric_default", isRecommended: false, imageRecommended: "symmetric_default_recommend", imageSelected: "symmetric_selected", imageSelectedRecommended: "symmetric_selected_recommend"),
        Composition(name: "TRIANGLE", description: "", image: "triangle_default", isRecommended: false, imageRecommended: "triangle_default_recommend", imageSelected: "triangle_selected", imageSelectedRecommended: "triangle_selected_recommend")
    ]
    
    var recommendedCompositions: [Composition] = []
    
    init(ml: MachineLearningClassificationLayer){
        self.mlcLayer =  ml
        self.activeID = compositions.first!.id
    }
    
    func findComposition(withName name: String) -> String? {
        recommendedCompositions = []
        
        if let index = compositions.firstIndex(where: { $0.name.lowercased() == name }) {
//            print(index)
            // Set the recommended status for the selected composition
            compositions[index].isRecommended = true

            // Reset isRecommended for all other compositions
            for i in 0..<compositions.count {
                if i != index {
                    compositions[i].isRecommended = false
                }
            }

//            for i in 0..<compositions.count {
//                print(compositions[i].name)
//            }

            return compositions[0].name
        }
        
        return nil
    }
    
    // Update the active composition based on ID change
    func updateActiveComposition(id: UUID?) {
        // Check if the id is not nil
        if let id = id {
            // Find the composition that matches the given UUID
            if let composition = compositions.first(where: { $0.id == id }) {
                activeComposition = composition.name  // Set activeComposition to the name of the found composition
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred() // Provide haptic feedback
            }
        }
    }
}


