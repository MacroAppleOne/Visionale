import Foundation
import UIKit
import SwiftUI

class CompositionViewModel: ObservableObject {
    @Published var activeID: UUID?
    @Published var activeComposition: String = "Center"
    @Published var compositions: [Composition] = [
        Composition(name: "CENTER", description: "", image: "center_default", isRecommended: false, imageRecommended: "center_default_recommend", imageSelected: "center_selected", imageSelectedRecommended: "center_selected_recommend"),
        Composition(name: "CURVED", description: "", image: "curved_default", isRecommended: false, imageRecommended: "curved_default_recommend", imageSelected: "curved_selected", imageSelectedRecommended: "curved_selected_recommend"),
        Composition(name: "DIAGONAL", description: "", image: "diagonal_default", isRecommended: false, imageRecommended: "diagonal_default_recommend", imageSelected: "diagonal_selected", imageSelectedRecommended: "diagonal_select_recommend"),
        Composition(name: "GOLDEN RATIO", description: "", image: "golden_default", isRecommended: false, imageRecommended: "golden_default_recommend", imageSelected: "golden_selected", imageSelectedRecommended: "golden_selected_recommend"),
        Composition(name: "RULE OF THIRDS", description: "", image: "rot_default", isRecommended: false, imageRecommended: "rot_default_recommend", imageSelected: "rot_selected", imageSelectedRecommended: "rot_selected_recommend"),
        Composition(name: "SYMMETRIC", description: "", image: "symmetric_default", isRecommended: false, imageRecommended: "symmetric_default_recommend", imageSelected: "symmetric_selected", imageSelectedRecommended: "symmetric_selected_recommend"),
        Composition(name: "TRIANGLE", description: "", image: "triangle_default", isRecommended: false, imageRecommended: "triangle_default_recommend", imageSelected: "triangle_selected", imageSelectedRecommended: "triangle_selected_recommend")
    ]
    
    
    var mlcLayer: MachineLearningClassificationLayer? 
    
    
    @Published var recommendedCompositions: String = ""
    
    
    init() {
        activeID = compositions.first?.id
//        self.mlcLayer = mlcLayers
    }
    
    private func getCompositionsFromML() {
        guard let mlcLayer = self.mlcLayer else { return }
        recommendedCompositions = mlcLayer.predictionLabels ?? ""
    }
    
    func findComposition(withName name: String) -> Bool? {
        
        if var index = compositions.firstIndex(where: { $0.name == name }){
            compositions[index].isRecommended = true
            return compositions[index].isRecommended
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


