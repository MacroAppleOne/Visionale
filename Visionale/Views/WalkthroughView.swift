import SwiftUI
@MainActor
struct WalkthroughView<CameraModel: Camera>: View {
    //
    @State private var currentStep = 0
    @State private var ballYPosition: CGFloat = 0 // Ball's vertical position
    @State private var ballXPosition: CGFloat = 0
    @State private var ballScale: CGFloat = 1
    @State private var isHighlighted: Bool = true
    
    //Symbol Animation
    @State private var symbolOffsetX: CGFloat = 50
    @State private var movingRight = true // Track animation direction
    @State private var isRotated = true
    @State private var rotation: CGFloat = 0
    
    @State public var camera: CameraModel
    
    @EnvironmentObject var session: OnboardingService
    
    
    //
    
    
    private let description: [Text] = [
        Text("Swipe through our selection of \(Text("framing grids").foregroundColor(.accentColor)) to find the grid that best suits your vision."),
        Text("Let our AI guide you to the best possible shot. The \(Text("thumbs-up icon").foregroundColor(.base)) highlights the \(Text("recommended framing").foregroundColor(.accentColor)) based on your object and surroundings."),
        Text("\(Text("Tap to instantly switch").foregroundColor(.accentColor)) to the AI-recommended framing for your shot. This button will only show up for a few seconds."),
        Text("\(Text("Double-tap").foregroundColor(.accentColor)) to rotate and find the ideal grid overlay."),
        Text("Position your camera, \(Text("until the circles match up").foregroundColor(.accentColor)), and you’re ready to capture your shot."),
        Text("\(Text("Shake").foregroundColor(.accentColor)) or \(Text("Tap the screen 3 times").foregroundColor(.accentColor)) to refresh the object scanner if the blue circle disappears.")
    ]
    //
    private let steps: [CGRect] = [
        CGRect(x: 0, y: UIScreen.main.bounds.height * 0.47, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.23),
        CGRect(x: UIScreen.main.bounds.width * 0.78, y: UIScreen.main.bounds.height * 0.64, width: 50, height: 50),
        CGRect(x: UIScreen.main.bounds.width * 0.15, y: UIScreen.main.bounds.height * 0.09, width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.06),
        CGRect(x: 0, y: UIScreen.main.bounds.height * 0.09, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5),
        CGRect(x: 0, y: UIScreen.main.bounds.height * 0.09, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5),
        CGRect(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5 , width: 0, height: 0)
        
    ]
    
    var body: some View {
        ZStack {
            VStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea(.all)
                
            }
            
            // Highlight overlay
            if currentStep <= steps.count {
                HighlightOverlay(stepRect: steps[currentStep], ballScale: $ballScale, isHighlighted: $isHighlighted)
                    .onTapGesture {
                        startBounceAnimation() // Trigger next step when tapped
                        if(currentStep == 5) {
                            print("masuk")
                            
                            session.completeWalkthrough()
                            
                            
                        }
                    }
                
                VStack {
                    // Position text based on current step
                    description[currentStep]
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .textCase(.uppercase)
                        .fontWeight(.medium)
                        .font(.subheadline)
                        .padding(20)
                        .position(
                            x: currentStep == 1 ? steps[currentStep].midX - 150 : steps[currentStep].midX,
                            y:{ if currentStep == 1 {
                                steps[currentStep].maxY - 150
                            } else if currentStep == 2{
                                steps[currentStep].maxY + 60
                            } else if currentStep == 3 {
                                steps[currentStep].minY - 40
                            } else if currentStep == 4 {
                                steps[currentStep].maxY + 50
                            }
                                else {
                                    steps[currentStep].minY - 60
                                }
                            }()
                        )
                    
                    if currentStep == 0 {
                        Image("handgesture")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .font(.largeTitle)
                            .offset(x: symbolOffsetX, y: 0)
                            .foregroundStyle(.white)
                            .onAppear {
                                animateSymbol()
                            }
                            .position(x: steps[currentStep].midX, y: 185)
                    } else if currentStep == 5 {
                        HStack{
                            Image("shake")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                                .onAppear {
                                    animateShake()
                                }
                                .rotationEffect(.degrees(rotation))
                                .position(x: steps[currentStep].midX, y: 165)
                        }
                    }
                }
                
                
                VStack{
                    Text("\(currentStep + 1) / 6".uppercased())
                        .font(.caption)
                        .fontWidth(.expanded)
                        .foregroundStyle(Color.gray.opacity(0.8))
                        .padding(.bottom)
                    
                    Text("Tap anywhere to continue".uppercased())
                        .font(.caption)
                        .fontWidth(.expanded)
                        .foregroundStyle(Color.gray.opacity(0.8))
                        .padding(.bottom)
                }
                .position(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.8)
            }
            
            
            
            
            
            
        }
    }
    
    func animateSymbol() {
        withAnimation(.easeInOut(duration: 3)) {
            // Toggle the direction and set the target offset
            if movingRight {
                symbolOffsetX = -50 // Move off-screen to the right
            } else {
                symbolOffsetX = 50 // Move off-screen to the left
            }
        }
        
        // Toggle direction and start the animation again after it completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            movingRight.toggle()
            animateSymbol()
        }
    }
    
    func animateShake() {
        withAnimation(.easeInOut(duration: 0.2)) {
            // Toggle the direction and set the target offset
            if isRotated {
                rotation = 25 // Move off-screen to the right
            } else {
                rotation = -25 // Move off-screen to the left
            }
        }
        
        // Toggle shake and start the animation again after it completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isRotated.toggle()
            animateShake()
        }
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            

            withAnimation{
                ballScale = 0
                isHighlighted = false
            }
            // Disable animation for position change only
            withAnimation() {
                currentStep += 1
            }
            
            
            // Delay the scaling back up to give time for the movement to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // Adjust delay as needed
                withAnimation(.spring()) { // Use a spring animation for smooth scaling
                    ballScale = 1.0
                    if(currentStep == 5) {
                        isHighlighted = false
                    } else {
                        isHighlighted = true
                    }
                    
                    
                }
            }
            print(currentStep)
            
        }
        
    }
    //
    //    // Function to start the bounce animation
    func startBounceAnimation() {
        guard currentStep < steps.count else { return }
        // Use DispatchQueue to delay the execution of nextStep() after the bounce completes
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if currentStep < steps.count - 1 {
                nextStep()
            } else {
                
            }
        }
    }
}


struct HighlightOverlay: View {
    let stepRect: CGRect
    @Binding var ballScale: CGFloat
    @Binding var isHighlighted: Bool
    @State private var animatedHighlight: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark overlay with the mask applied only to the cutout area
                Color.black.opacity(0.85)
                    .edgesIgnoringSafeArea(.all)
                    .mask(
                        // Mask with animated cutout shape
                        CutoutShape(rect: stepRect)
                            .fill(style: isHighlighted ? FillStyle(eoFill: true) : FillStyle())
                        
                    )
                
                // Highlight border (this will not be affected by the mask)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.accent, lineWidth: 3)
                    .frame(width: stepRect.width, height: stepRect.height)
                    .scaleEffect(ballScale, anchor: .center)
                    .position(x: stepRect.midX, y: stepRect.midY)
            }
        }
    }
}
//
//
//
struct CutoutShape: Shape {
    let rect: CGRect
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect) // Outer rectangle covering the whole screen
        path.addRoundedRect(in: self.rect, cornerSize: CGSize(width: 10, height: 10)) // Cutout rectangle
        return path
    }
}
//
