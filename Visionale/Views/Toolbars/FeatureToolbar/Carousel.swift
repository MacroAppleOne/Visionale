import SwiftUI

struct Carousel<CameraModel: Camera>: View {
    @State var camera: CameraModel
    @State private var rotationAngle: Angle = .zero
    @State private var lastRotationAngle: Angle = .zero
    @State private var currentButton: Int = 0
    @State private var lastCurrentButton: Int = 0
    let totalButtonArc: Double = 75.0
    let buttonSpacing: CGFloat = 42 // Adjust for horizontal spacing
    @State private var translationOffset: CGFloat = 0
    @State private var lastTranslationOffset: CGFloat = 0
    
    @State var geometry: GeometryProxy
    
    func HalfRotaryDial(geometry: GeometryProxy) -> some View {
        // Precompute rotation angle limits
        let anglePerButton = totalButtonArc / Double(camera.compositions.count - 1)
        let startAngle = -90.0 - totalButtonArc / 2.0
        
        let firstButtonAngle = startAngle + Double(0) * anglePerButton // Index 0
        let lastButtonAngle = startAngle + Double(camera.compositions.count - 1) * anglePerButton // Last index
        
        let rotationAngleFirst = -90.0 - firstButtonAngle // When first button is at top
        let rotationAngleLast = -90.0 - lastButtonAngle   // When last button is at top
        
        let safeZoneDegrees = 10.0
        let maxRotationAngle = rotationAngleFirst + safeZoneDegrees
        let minRotationAngle = rotationAngleLast - safeZoneDegrees
        
        return ZStack {
            let radius = min(geometry.size.width - 144, geometry.size.height - 144) / 2
            // Placing compositions along the arc or in a horizontal line
            ForEach(Array(camera.compositions.enumerated()), id: \.offset) { index, element in
                let anglePerButton = totalButtonArc / Double(camera.compositions.count - 1)
                let startAngle = -90.0 - totalButtonArc / 2.0 // Center the compositions around the top
                let buttonAngle = startAngle + Double(index) * anglePerButton
                let angle = Angle.degrees(buttonAngle)
                
                CompositionButton(for: element)
                    .rotationEffect(camera.isFramingCarouselEnabled ? -rotationAngle : .zero) // Keep compositions upright
                    .offset(
                        x: camera.isFramingCarouselEnabled ? radius * CGFloat(cos(angle.radians)) : (CGFloat(index) - (CGFloat(camera.compositions.count - 1) / 2.0)) * buttonSpacing + translationOffset,
                        y: camera.isFramingCarouselEnabled ? radius * CGFloat(sin(angle.radians)) : 0
                    )
                    .onTapGesture {
                        // Make the button trigger on tap, change composition
                        camera.updateActiveComposition(camera.compositions[index].name)
                        lastCurrentButton = currentButton
                        
                    }
            }
        }
        .rotationEffect(camera.isFramingCarouselEnabled ? rotationAngle : .zero) // Rotate dial if carousel is on
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Update the rotation angle based on the drag gesture
                    rotationAngle = .degrees(value.translation.width / 2) + lastRotationAngle
                    // Limit rotationAngle within allowed range
                    rotationAngle.degrees = max(min(rotationAngle.degrees, maxRotationAngle), minRotationAngle)
                    updateCurrentButton()
                    
                    if currentButton != lastCurrentButton {
                        handleButtonChanges(direction: value.translation.width >= 0 ? 1 : -1)
                        camera.updateActiveComposition(camera.compositions[currentButton].name)
                        lastCurrentButton = currentButton
                    }
                    withAnimation {
                        camera.isFramingCarouselEnabled = true
                    }
                }
                .onEnded { value in
                    // Update the rotation angle when the drag ends
                    rotationAngle = .degrees(value.translation.width) + lastRotationAngle
                    // Limit rotationAngle within allowed range
                    rotationAngle.degrees = max(min(rotationAngle.degrees, maxRotationAngle), minRotationAngle)
                    // Snap to the nearest button
                    updateCurrentButton()
                    snapToNearestButton()
                    // Update the last rotation angle to the snapped position
                    lastRotationAngle = rotationAngle
                    lastCurrentButton = currentButton
                    withAnimation {
                        camera.isFramingCarouselEnabled = false
                    }
                }
        )
    }
    
    // Function to handle button changes
    func handleButtonChanges(direction: Int) {
        let buttonCount = camera.compositions.count
        var index = lastCurrentButton
        while index != currentButton {
            index = (index + direction + buttonCount) % buttonCount
            lastCurrentButton = index
        }
    }
    
    // Function to update the current button at the top middle position
    func updateCurrentButton() {
        let anglePerButton = totalButtonArc / Double(camera.compositions.count - 1)
        let startAngle = -90.0 - totalButtonArc / 2.0
        var minDifference = Double.infinity
        var selectedButtonIndex = 0
        
        for index in 0..<camera.compositions.count {
            let buttonAngle = startAngle + Double(index) * anglePerButton
            let effectiveAngle = buttonAngle + rotationAngle.degrees
            let difference = angularDifference(effectiveAngle, -90.0) // Compare with top position
            if difference < minDifference {
                minDifference = difference
                selectedButtonIndex = index
            }
        }
        currentButton = selectedButtonIndex
    }
    
    // Snap rotation to the nearest button
    func snapToNearestButton() {
        let anglePerButton = totalButtonArc / Double(camera.compositions.count - 1)
        let startAngle = -90.0 - totalButtonArc / 2.0
        let buttonAngle = startAngle + Double(currentButton) * anglePerButton
        let targetRotation = -90.0 - buttonAngle
        
        withAnimation(.easeOut) {
            rotationAngle = .degrees(targetRotation)
        }
    }
    
    // Helper function to calculate the smallest angular difference
    func angularDifference(_ angle1: Double, _ angle2: Double) -> Double {
        var difference = (angle1 - angle2).truncatingRemainder(dividingBy: 360)
        if difference > 180 {
            difference -= 360
        } else if difference < -180 {
            difference += 360
        }
        return abs(difference)
    }
    
    var body: some View {
        VStack {
            CompositionTextView
            HalfRotaryDial(geometry: geometry)
                .onTapGesture {
                    // Set isFramingCarouselEnabled to true
                    withAnimation(.easeInOut) {
                        camera.isFramingCarouselEnabled = true
                    }
                    // Revert back to false after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut) {
                            camera.isFramingCarouselEnabled = false
                        }
                    }
                }
        }
        .offset(y: -20)
    }
    
    @ViewBuilder
    var CarouselBackground: some View {
        if (camera.isFramingCarouselEnabled){
            Circle()
                .fill(.regularMaterial)
        }
    }
    
    // Subview for each composition's button (unchanged)
    func CompositionButton(for composition: Composition) -> some View {
        Image(composition.imageName(isActive: camera.activeComposition == composition.name, image: composition.image, isRecommended: camera.mlcLayer?.predictionLabel!.uppercased().replacingOccurrences(of: "_", with: " ") == composition.name.uppercased()))
            .resizable()
            .frame(width: 36, height: 36)
            .animation(.easeInOut(duration: 0.4), value: camera.activeComposition)
    }
    
    // Subview for active composition text (unchanged)
    var CompositionTextView: some View {
        Text(camera.activeComposition)
            .foregroundColor(.darkGradient)
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(8)
            .background(Color.accent)
            .cornerRadius(4)
    }
}


extension Composition {
    func imageName(isActive: Bool, image: String, isRecommended: Bool) -> String {
        var imageName = image
        
        if isActive && isRecommended {
            imageName += "_selected_recommend"
        } else if isActive {
            imageName += "_selected"
        } else if isRecommended {
            imageName += "_default_recommend"
        } else {
            imageName += "_default"
        }
        return imageName
    }
}
