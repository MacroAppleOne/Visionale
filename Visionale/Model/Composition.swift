import Foundation

struct Composition: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: String
    var isRecommended: Bool
}


