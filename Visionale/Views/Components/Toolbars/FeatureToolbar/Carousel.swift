import SwiftUI

struct Carousel<CameraModel: Camera>: View {
    @Binding var camera: CameraModel
    @ObservedObject var viewModel: CompositionViewModel = CompositionViewModel()
    
    var body: some View {
        ZStack {
            // Half circle background shape
            HalfCircleShape()
                .fill(Color.black)
                .opacity(0.3)
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height / 2 + 35)
            
                ScrollView(.horizontal) {
                    HStack(spacing: 30) {
                        ForEach(viewModel.compositions) { composition in
                            VStack {
                                if(viewModel.activeID == composition.id && composition.isRecommended == true){
                                    Image(composition.imageSelectedRecommended)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                } else if (viewModel.activeID == composition.id && composition.isRecommended == false){
                                    Image(composition.imageSelected)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                } else if (viewModel.activeID != composition.id && composition.isRecommended == true){
                                    Image(composition.imageRecommended )
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                } else {
                                    Image(composition.image)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                
                                Text(composition.name)
                                    .font(.subheadline)
                                    .foregroundStyle(viewModel.activeID == composition.id ? .accent : .activeCircle)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(1.5)
                                    .frame(width: 125)
                            }
                            .frame(width: 80, height: 150)
                            .visualEffect {
                                view, proxy in view
                                    .offset(y: offset(proxy))
                                    .offset(y: scale(proxy) * 2)
                            }
                            .scrollTransition(.interactive, axis: .horizontal) {
                                view, phase in view
                            }
                        }
                    }
                    
                }.offset(y: -40)
                .scrollTargetLayout()
                .safeAreaPadding((UIScreen.main.bounds.width - 70) / 2)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $viewModel.activeID)
                .onChange(of: viewModel.activeID, perform: { newID in
                    viewModel.updateActiveComposition(id: newID)
                    print("test")
                    print(viewModel.recommendedCompositions)
                })
            
            
            Rectangle()
                .fill(Color.frameRectangle)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding(.top, 160)
        }
        .onAppear {
            viewModel.mlcLayer = camera.captureService.mlcLayer
        }
    }
    
    // Circular Slider View Offset
    nonisolated func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return progress < 0 ? progress * -35 : progress * 35
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
    
    func compositionRecommended(withName name: String, in compositions: [Composition]) -> Bool {
        return compositions.contains { $0.name == name }
    }

    
    
}

// Custom Half Circle Shape
struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY), // Center at bottom
                    radius: rect.width * 0.75,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

//#Preview {
//    Carousel()
//}
