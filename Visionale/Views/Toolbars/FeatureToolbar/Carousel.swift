
import SwiftUI
import Combine

struct Carousel<CameraModel: Camera>: View {
    @State var camera: CameraModel
    @State private var hideCarousel: DispatchWorkItem?
    @State private var lastInteraction = Date()
    @State private var cancellable: AnyCancellable?
        
    var body: some View {
        VStack {
            compositionTextView
            if !camera.isFramingCarouselEnabled {
                ZStack{
                    carouselImagesHStack
                        .safeAreaPadding(.all)
                        .padding(.trailing, 5)
                }
                .transition(.move(edge: .bottom))
            } else {
                compositionCarousel
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        lastInteraction = Date() // Initialize interaction time
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            cancellable = Timer.publish(every: 0.5, on: .main, in: .common)
                                .autoconnect()
                                .sink { _ in
                                    // Check if 2 seconds have passed since last interaction
                                    if Date().timeIntervalSince(lastInteraction) > 2 {
                                        withAnimation(.easeOut) {
                                            camera.isFramingCarouselEnabled = false
                                        }
                                    }
                                }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    var compositionCarousel: some View {
        GeometryReader { geometry in
            ZStack {
                HalfCircleShape()
                    .fill(.darkGradient)
                    .opacity(0.7)
                    .frame(
                        width: geometry.size.width + 10,
                        height: geometry.size.height / 2 + 35
                    )
                
                ScrollView(.horizontal) {
                    HStack(spacing: -7) {
                        ForEach(camera.compositions) { composition in
                            compositionButton(for: composition)
                        }
                    }
                    .padding(.horizontal) // Ensure some padding around the content
                }
                .offset(y: -135)
                .scrollTargetLayout()
                .safeAreaPadding((geometry.size.width - 70) / 2)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $camera.activeID)
                .onChange(of: camera.activeID) { _, newID in
                    camera.updateActiveComposition(id: newID)
                    
                    switch camera.activeComposition {
                    case "CENTER":
                        camera.mlcLayer?.setGuidanceSystem(CenterGuidance())
                    case "DIAGONAL":
                        camera.mlcLayer?.setGuidanceSystem(LeadingLineGuidance())
                    case "GOLDEN RATIO":
                        camera.mlcLayer?.setGuidanceSystem(GoldenRatioGuidance())
                    case "RULE OF THIRDS":
                        camera.mlcLayer?.setGuidanceSystem(RuleOfThirdsGuidance())
                    case "SYMMETRIC":
                        camera.mlcLayer?.setGuidanceSystem(SymmetricGuidance())
                    default:
                        camera.mlcLayer?.setGuidanceSystem(nil)
                    }
                    
                    lastInteraction = Date()
                }
                .onChange(of: (camera.mlcLayer?.predictionLabel) ?? "Unknown") { _, newComposition in
                    camera.findComposition(withName: newComposition)
                }
            }
            .offset(y: geometry.size.height - 200)
            
        }
    }
    
    // Subview for Carousel Images when isCarouselHidden is true
    @ViewBuilder
    var carouselImagesHStack: some View {
        GeometryReader { geometry in
            let totalWidth = CGFloat(camera.compositions.count) * 80 // Total width of all compositions
            let centerOffset = (geometry.size.width - 195) / 2 // Calculate the offset to center the first image
            
            HStack(spacing: -25) {
                ForEach(camera.compositions.indices, id: \.self) { index in
                    let composition = camera.compositions[index]
                    
                    VStack {
                        Image(composition.imageName(isActive: camera.activeID == composition.id, image: composition.image))
                            .resizable()
                            .frame(width: 35, height: 35)
                            .opacity(1.0 - Double(index) * 0.25)
                    }
                    .frame(width: 80, height: 150)
                    .animation(.easeInOut(duration: 0.3), value: camera.activeID) // Animate only on activeID change
                }
            }
            .frame(width: totalWidth) // Set the total width of the HStack
            .clipped() // Crop the content to fit within the frame
            .offset(x: centerOffset, y: geometry.size.height - 100) // Center the HStack by applying the calculated offset
        }
    }
    
    
    // Subview for each composition's button
    @ViewBuilder
    func compositionButton(for composition: Composition) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.4)) {
                camera.activeID = composition.id
            }
        }) {
            VStack {
                Image(composition.imageName(isActive: camera.activeID == composition.id, image: composition.image))
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .frame(width: 80, height: 150)
            .scaleEffect(camera.activeID == composition.id ? 1.24 : 1.0)
            .visualEffect {
                view, proxy in
                view
                    .offset(y: offset(proxy))
                    .offset(y: scale(proxy) * 2)
            }
            .scrollTransition(.interactive, axis: .horizontal) {
                view, phase in
                view
            }
            .animation(.easeInOut(duration: 0.4), value: camera.activeID)
        }
    }
    
    // Subview for active composition text
    @ViewBuilder
    var compositionTextView: some View {
        Text(camera.activeComposition)
            .foregroundColor(.darkGradient)
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(8)
            .background(Color.accent)
            .background(Material.thin)
            .cornerRadius(4)
            .offset(y: camera.isFramingCarouselEnabled ? 350 : 400)
    }
    
    // Circular Slider View Offset
    nonisolated func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return progress < 0 ? progress * -27 : progress * 27
    }
    
    nonisolated func scale(_ proxy: GeometryProxy) -> CGFloat {
        let progress = min(max(progress(proxy), -1), 1)
        return progress < 0 ? 1 + progress : 1 - progress
    }
    
    nonisolated func progress(_ proxy: GeometryProxy) -> CGFloat {
        let viewWidth = proxy.size.width
        let minX = (proxy.bounds(of: .scrollView)?.minX ?? 0)
        return minX / viewWidth
    }
    
    
}

// Custom Half Circle Shape
struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(
                x: rect.midX,
                y: rect.maxY
            ),
            radius: rect.width * 0.75,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

extension Composition {
    func imageName(isActive: Bool, image: String) -> String {
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


#Preview {
    Carousel(camera: CameraModel())
}
