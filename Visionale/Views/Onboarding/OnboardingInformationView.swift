//
//  OnboardingInformationView.swift
//  Visionalé
//
//  Created by Kyrell Leano Siauw on 23/10/24.
//

import SwiftUI


struct OnboardingInformationView: View {
    @EnvironmentObject var session: OnboardingService
    
    @State private var currentStep = 0
    init(){
        UIScrollView.appearance().bounces = false
    }
    
    struct onBoardingStep {
        let systemVideoName: String
        let title: String
        let description: String
    }
    
    private let onBoardingSteps = [
        onBoardingStep(systemVideoName: "", title: "AI Framing Recommendation", description: "Personalize framing based on your surroundings. Adjusts to your environment to help you take amazing images in any setting."),
        onBoardingStep(systemVideoName: "", title: "Grid Overlay", description: "To line every photo with your background, just toggle grids on or off and tweak settings to match your frame style."),
        onBoardingStep(systemVideoName: "", title: "Real-Time Composition Guidance", description: "Real-time positioning suggestions make great photographs easier. Visual clues place you for the perfect shot every time.")
    ]
    
    var body: some View {
        NavigationView{
            ZStack {
                VStack{
                    MeshGradient(
                        width: 5,
                        height: 5,
                        points: [
                            // 5x5 grid points
                            [0.0, 0.0], [0.25, 0.0], [0.5, 0.0], [0.75, 0.0], [1.0, 0.0],  // Top row
                            [0.0, 0.25], [0.25, 0.25], [0.5, 0.25], [0.75, 0.25], [1.0, 0.25],  // Second row
                            [0.0, 0.5], [0.25, 0.5], [0.5, 0.5], [0.75, 0.5], [1.0, 0.5],  // Third row
                            [0.0, 0.75], [0.25, 0.75], [0.5, 0.75], [0.75, 0.75], [1.0, 0.75],  // Fourth row
                            [0.0, 1.0], [0.25, 1.0], [0.5, 1.0], [0.75, 1.0], [1.0, 1.0]   // Bottom row
                        ],
                        colors: [
                            // Corresponding colors for each point in the 5x5 grid
                            .lightGradient, .lightGradient, .lightGradient, .accentColor, .accentColor,   // Top row colors
                            .accentColor, .accentColor, .accentColor, .lightGradient, .lightGradient,  // Second row colors
                            .darkGradient.mix(with: .accentColor, by: 0.6), .accentColor, .accentColor, .accentColor, .accentColor,    // Third row colors
                            .darkGradient, .darkGradient.mix(with: .accentColor, by: 0.2), .accentColor.mix(with: .darkGradient, by: 0.7), .darkGradient.mix(with: .accentColor, by: 0.2), .darkGradient,  // Fourth row colors
                            .darkGradient, .darkGradient, .darkGradient, .darkGradient, .darkGradient  // Bottom row colors
                        ]
                    ) .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }
                
                
                
                VStack {
                    ZStack{
                        Rectangle()
                            .fill(.darkGradient) // Change this color to whatever you want
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2) // Half screen height
                        Image("systemVideoName")
                            .resizable()
                        VStack{
                            HStack{
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 2)){
                                        session.completeOnboarding()
                                    }
                                   
                                }){
                                    Text("Skip")
                                        .padding(16)
                                        .foregroundStyle(.accent)
                                }
                            }.padding(.top, 50)
                                .padding(.trailing, 10)
                            Spacer()
                            
                        }
                        
                    }
                    
                    TabView(selection: $currentStep){
                        ForEach(0..<onBoardingSteps.count, id: \.self){ it in
                            VStack(alignment: .leading){
                                Text(onBoardingSteps[it].title)
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text(onBoardingSteps[it].description)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .fontWeight(.regular)
                            }
                            .tag(it)
                            .padding(.horizontal, 35)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    VStack{
                        HStack{
                            ForEach(0..<onBoardingSteps.count, id: \.self){ index in
                                if index == currentStep {
                                    Rectangle()
                                        .frame(width: 25, height: 5)
                                        .cornerRadius(8)
                                        .foregroundColor(.lightGradient)
                                } else {
                                    Rectangle()
                                        .frame(width: 15, height: 5)
                                        .cornerRadius(8)
                                        .foregroundColor(.gray)
                                }
                                
                            }
                            
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    if self.currentStep < onBoardingSteps.count - 1 {
                                        self.currentStep += 1
                                    } else {
                                        session.completeOnboarding()
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.right.circle")
                                    .resizable()
                                    .frame(width: 55, height: 55)
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 45)
                        }.padding(.bottom, 150)
                        
                    }
                    .padding(.horizontal, 40)
                    .edgesIgnoringSafeArea(.all)
                    
                }
            }
        }
    }
}


#Preview {
    OnboardingInformationView()
}
