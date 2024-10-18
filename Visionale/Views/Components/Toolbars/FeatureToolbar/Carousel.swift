import SwiftUI

struct Carousel<CameraModel: Camera>: View {
    var camera: CameraModel
    @ObservedObject var viewModel: CompositionViewModel
    @State private var compositionName: String = ""
    
    init(camera: CameraModel){
        self.viewModel = CompositionViewModel(ml: camera.captureService.mlcLayer)
        self.camera = camera
    }
    var body: some View {
        ZStack {
            // Half circle background shape
            HalfCircleShape()
                .fill(Color.circle)
                .opacity(0.7)
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height / 2 + 35)
            
            
            ScrollView(.horizontal) {
                HStack(spacing: -7) {
                    ForEach(viewModel.compositions) { composition in
                        VStack {
                            if(viewModel.activeID == composition.id && composition.isRecommended == true){
                                Image(composition.imageSelectedRecommended)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            } else if (viewModel.activeID == composition.id && composition.isRecommended == false){
                                Image(composition.imageSelected)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            } else if (viewModel.activeID != composition.id && composition.isRecommended == true){
                                Image(composition.imageRecommended)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            } else {
                                Image(composition.image)
                                    .resizable()
                                    .frame(width: 35, height: 35)
                            }
                        }
                        .frame(width: 80, height: 150)
                        .scaleEffect(viewModel.activeID == composition.id ? 1.24 : 1.0)
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
            }
            .offset(y: -40)
            .scrollTargetLayout()
            .safeAreaPadding((UIScreen.main.bounds.width - 70) / 2)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: Binding($viewModel.activeID))
            .onChange(of: viewModel.activeID){ oldID, newID in
                viewModel.updateActiveComposition(id: newID)
                if let composition = viewModel.compositions.first(where: { $0.id == newID }) {
                    compositionName = composition.name
                }
                
            }
            .onChange(of: viewModel.mlcLayer.predictionLabels) { oldLabels, newLabels in
                guard let labels = newLabels else { return }
            }
            
            Text(compositionName)
                .foregroundColor(.darkGradient)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(.base)
                .cornerRadius(5)
                .offset(y: -100)
            
            
            
            Rectangle()
                .fill(Color.frameRectangle)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.top, 280)
        }
        .onAppear {
            viewModel.mlcLayer = camera.captureService.mlcLayer
        }
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
    
    nonisolated func compositionRecommended(withName name: String, in compositions: [Composition]) -> Bool {
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
