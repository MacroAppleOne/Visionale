import SwiftUI

struct Carousel: View {
    
    var colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan]
    var compositions: [String] = ["NONE","CENTER", "CURVED", "DIAGONAL", "GOLDEN RATIO", "RULE OF THIRDS", "SYMMETRIC", "TRIANGLE"]
    @State private var activeID: Int? = 0
    @State private var activeCompositions: String = "Center"
    
    
    var body: some View {
        ZStack {
            // Half circle background shape
            HalfCircleShape()
                .fill(Color.black)
                .opacity(0.2)
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height / 2 + 35)
            
            // Horizontal ScrollView
            ScrollView(.horizontal) {
                HStack(spacing: 45) {
                    ForEach(0...7, id: \.self) { index in
                        VStack {
                            Circle()
                                .fill(activeID == index ? Color.activeCircle : Color.inActiveCircle)
                                .frame(width: 10, height: 10)
                                .padding(.bottom, 10)
                            
                            Text(compositions[index])
                                .font(.subheadline)
                                .foregroundStyle(activeID == index ? Color.activeCircle : Color.inActiveCircle)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .minimumScaleFactor(1.5)
                                .frame(width: 125)
                        }
                        .frame(width: 70, height: 100)
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
                .offset(y: -35)
                .scrollTargetLayout()
            }
            .safeAreaPadding((UIScreen.main.bounds.width - 70) / 2)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $activeID)
            .onChange(of: activeID, perform: { newID in
                print("terganti")
                if let id = newID {
                    activeCompositions = compositions[id]
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            })
//            .onChange(of: activeID) { newID in
//                print("terganti")
//                if let id = newID {
//                    activeCompositions = compositions[id]
//                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//                }
//            }
            
            Rectangle()
                .fill(Color.frameRectangle)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding(.top, 165)
            
            
        }
    }
    
    // Circular Slider View Offset
    func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return progress < 0 ? progress * -20 : progress * 20
    }
    
    func scale(_ proxy: GeometryProxy) -> CGFloat {
        let progress = min(max(progress(proxy), -1), 1)
        return progress < 0 ? 1 + progress : 1 - progress
    }
    
    func progress(_ proxy: GeometryProxy) -> CGFloat {
        let viewWidth = proxy.size.width
        let minX = (proxy.bounds(of: .scrollView)?.minX ?? 0)
        return minX / viewWidth
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

#Preview {
    Carousel()
}
