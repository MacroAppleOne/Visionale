//
//  LeadingLineGrid.swift
//  Visionale
//
//  Created by Nico Samuelson on 12/11/24.
//

import SwiftUI

struct LeadingLineGrid<CameraModel: Camera>: View {
    @State var camera: CameraModel
    
    var body: some View {
        GeometryReader { gr in
            let width = gr.size.width
            let height = gr.size.height
            
            let rectSize = width / 8
            
            let xOffset = (width - rectSize) / 2
            let yOffset = (height - rectSize) / 2
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0.70738*width, y: 0.46851*height))
                    path.addCurve(to: CGPoint(x: 0.70865*width, y: 0.46947*height), control1: CGPoint(x: 0.70808*width, y: 0.46851*height), control2: CGPoint(x: 0.70865*width, y: 0.46894*height))
                    path.addLine(to: CGPoint(x: 0.70865*width, y: 0.47805*height))
                    path.addCurve(to: CGPoint(x: 0.70738*width, y: 0.47901*height), control1: CGPoint(x: 0.70865*width, y: 0.47858*height), control2: CGPoint(x: 0.70808*width, y: 0.47901*height))
                    path.addCurve(to: CGPoint(x: 0.70611*width, y: 0.47805*height), control1: CGPoint(x: 0.70668*width, y: 0.47901*height), control2: CGPoint(x: 0.70611*width, y: 0.47858*height))
                    path.addLine(to: CGPoint(x: 0.70611*width, y: 0.47042*height))
                    path.addLine(to: CGPoint(x: 0.69593*width, y: 0.47042*height))
                    path.addCurve(to: CGPoint(x: 0.69466*width, y: 0.46947*height), control1: CGPoint(x: 0.69523*width, y: 0.47042*height), control2: CGPoint(x: 0.69466*width, y: 0.46999*height))
                    path.addCurve(to: CGPoint(x: 0.69593*width, y: 0.46851*height), control1: CGPoint(x: 0.69466*width, y: 0.46894*height), control2: CGPoint(x: 0.69523*width, y: 0.46851*height))
                    path.addLine(to: CGPoint(x: 0.70738*width, y: 0.46851*height))
                    path.closeSubpath()
                    path.move(to: CGPoint(x: 0.70828*width, y: 0.47014*height))
                    path.addLine(to: CGPoint(x: 0.00067*width, y: 1.00085*height))
                    path.addLine(to: CGPoint(x: -0.00113*width, y: 0.9995*height))
                    path.addLine(to: CGPoint(x: 0.70648*width, y: 0.46879*height))
                    path.addLine(to: CGPoint(x: 0.70828*width, y: 0.47014*height))
                    path.closeSubpath()
                    path.move(to: CGPoint(x: 0.70688*width, y: 0.53729*height))
                    path.addCurve(to: CGPoint(x: 0.70855*width, y: 0.5378*height), control1: CGPoint(x: 0.70753*width, y: 0.53708*height), control2: CGPoint(x: 0.70827*width, y: 0.53731*height))
                    path.addLine(to: CGPoint(x: 0.71302*width, y: 0.5457*height))
                    path.addCurve(to: CGPoint(x: 0.71235*width, y: 0.54695*height), control1: CGPoint(x: 0.7133*width, y: 0.54619*height), control2: CGPoint(x: 0.713*width, y: 0.54675*height))
                    path.addCurve(to: CGPoint(x: 0.71068*width, y: 0.54645*height), control1: CGPoint(x: 0.7117*width, y: 0.54716*height), control2: CGPoint(x: 0.71096*width, y: 0.54693*height))
                    path.addLine(to: CGPoint(x: 0.7067*width, y: 0.53942*height))
                    path.addLine(to: CGPoint(x: 0.69734*width, y: 0.5424*height))
                    path.addCurve(to: CGPoint(x: 0.69567*width, y: 0.5419*height), control1: CGPoint(x: 0.69669*width, y: 0.54261*height), control2: CGPoint(x: 0.69594*width, y: 0.54238*height))
                    path.addCurve(to: CGPoint(x: 0.69634*width, y: 0.54065*height), control1: CGPoint(x: 0.69539*width, y: 0.54141*height), control2: CGPoint(x: 0.69569*width, y: 0.54085*height))
                    path.addLine(to: CGPoint(x: 0.70688*width, y: 0.53729*height))
                    path.closeSubpath()
                    path.move(to: CGPoint(x: 0.70856*width, y: 0.53852*height))
                    path.addLine(to: CGPoint(x: 0.45985*width, y: 1.00014*height))
                    path.addLine(to: CGPoint(x: 0.45749*width, y: 0.99942*height))
                    path.addLine(to: CGPoint(x: 0.7062*width, y: 0.53781*height))
                    path.addLine(to: CGPoint(x: 0.70856*width, y: 0.53852*height))
                    path.closeSubpath()
                    path.move(to: CGPoint(x: 0.61616*width, y: 0.46856*height))
                    path.addCurve(to: CGPoint(x: 0.61699*width, y: 0.46975*height), control1: CGPoint(x: 0.61683*width, y: 0.46871*height), control2: CGPoint(x: 0.6172*width, y: 0.46925*height))
                    path.addLine(to: CGPoint(x: 0.61356*width, y: 0.47794*height))
                    path.addCurve(to: CGPoint(x: 0.61196*width, y: 0.47857*height), control1: CGPoint(x: 0.61335*width, y: 0.47845*height), control2: CGPoint(x: 0.61263*width, y: 0.47873*height))
                    path.addCurve(to: CGPoint(x: 0.61113*width, y: 0.47737*height), control1: CGPoint(x: 0.61129*width, y: 0.47841*height), control2: CGPoint(x: 0.61092*width, y: 0.47787*height))
                    path.addLine(to: CGPoint(x: 0.61418*width, y: 0.47009*height))
                    path.addLine(to: CGPoint(x: 0.60447*width, y: 0.4678*height))
                    path.addCurve(to: CGPoint(x: 0.60364*width, y: 0.4666*height), control1: CGPoint(x: 0.6038*width, y: 0.46764*height), control2: CGPoint(x: 0.60343*width, y: 0.46711*height))
                    path.addCurve(to: CGPoint(x: 0.60523*width, y: 0.46598*height), control1: CGPoint(x: 0.60385*width, y: 0.4661*height), control2: CGPoint(x: 0.60456*width, y: 0.46582*height))
                    path.addLine(to: CGPoint(x: 0.61616*width, y: 0.46856*height))
                    path.closeSubpath()
                    path.move(to: CGPoint(x: 0.61636*width, y: 0.47031*height))
                    path.addLine(to: CGPoint(x: -0.0108*width, y: 0.71569*height))
                    path.addLine(to: CGPoint(x: -0.01198*width, y: 0.714*height))
                    path.addLine(to: CGPoint(x: 0.61519*width, y: 0.46862*height))
                    path.addLine(to: CGPoint(x: 0.61636*width, y: 0.47031*height))
                    path.closeSubpath()
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.5), lineWidth: 1)
                
                Path { path in
                    path.addEllipse(in: CGRect(x: xOffset, y: yOffset, width: rectSize, height: rectSize))
                }
                .stroke(camera.mlcLayer?.guidanceSystem?.isAligned ?? false ? Color.accent.opacity(0.7) : Color.white.opacity(0.5), lineWidth: 1)
                .backgroundStyle(.clear)
            }
        }
    }
}


struct MyIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.69082*width, y: 0.63566*height))
        path.addCurve(to: CGPoint(x: 0.68979*width, y: 0.63456*height), control1: CGPoint(x: 0.69094*width, y: 0.63514*height), control2: CGPoint(x: 0.69048*width, y: 0.63465*height))
        path.addLine(to: CGPoint(x: 0.67851*width, y: 0.63308*height))
        path.addCurve(to: CGPoint(x: 0.67703*width, y: 0.63386*height), control1: CGPoint(x: 0.67781*width, y: 0.63299*height), control2: CGPoint(x: 0.67716*width, y: 0.63334*height))
        path.addCurve(to: CGPoint(x: 0.67807*width, y: 0.63496*height), control1: CGPoint(x: 0.67691*width, y: 0.63438*height), control2: CGPoint(x: 0.67738*width, y: 0.63487*height))
        path.addLine(to: CGPoint(x: 0.6881*width, y: 0.63627*height))
        path.addLine(to: CGPoint(x: 0.68635*width, y: 0.64379*height))
        path.addCurve(to: CGPoint(x: 0.68738*width, y: 0.6449*height), control1: CGPoint(x: 0.68623*width, y: 0.64431*height), control2: CGPoint(x: 0.68669*width, y: 0.64481*height))
        path.addCurve(to: CGPoint(x: 0.68885*width, y: 0.64412*height), control1: CGPoint(x: 0.68808*width, y: 0.64499*height), control2: CGPoint(x: 0.68874*width, y: 0.64464*height))
        path.addLine(to: CGPoint(x: 0.69082*width, y: 0.63566*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.68883*width, y: 0.63472*height))
        path.addLine(to: CGPoint(x: -0.00073*width, y: 0.99843*height))
        path.addLine(to: CGPoint(x: 0.00073*width, y: 0.99999*height))
        path.addLine(to: CGPoint(x: 0.6903*width, y: 0.63628*height))
        path.addLine(to: CGPoint(x: 0.68883*width, y: 0.63472*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.78244*width, y: 0.63556*height))
        path.addCurve(to: CGPoint(x: 0.78125*width, y: 0.63454*height), control1: CGPoint(x: 0.78248*width, y: 0.63503*height), control2: CGPoint(x: 0.78195*width, y: 0.63458*height))
        path.addLine(to: CGPoint(x: 0.76982*width, y: 0.634*height))
        path.addCurve(to: CGPoint(x: 0.76847*width, y: 0.6349*height), control1: CGPoint(x: 0.76912*width, y: 0.63397*height), control2: CGPoint(x: 0.76852*width, y: 0.63437*height))
        path.addCurve(to: CGPoint(x: 0.76966*width, y: 0.63591*height), control1: CGPoint(x: 0.76843*width, y: 0.63542*height), control2: CGPoint(x: 0.76896*width, y: 0.63587*height))
        path.addLine(to: CGPoint(x: 0.77982*width, y: 0.63639*height))
        path.addLine(to: CGPoint(x: 0.77918*width, y: 0.64401*height))
        path.addCurve(to: CGPoint(x: 0.78037*width, y: 0.64502*height), control1: CGPoint(x: 0.77913*width, y: 0.64453*height), control2: CGPoint(x: 0.77967*width, y: 0.64499*height))
        path.addCurve(to: CGPoint(x: 0.78172*width, y: 0.64413*height), control1: CGPoint(x: 0.78107*width, y: 0.64505*height), control2: CGPoint(x: 0.78167*width, y: 0.64465*height))
        path.addLine(to: CGPoint(x: 0.78244*width, y: 0.63556*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.78033*width, y: 0.63478*height))
        path.addLine(to: CGPoint(x: 0.22892*width, y: 0.99928*height))
        path.addLine(to: CGPoint(x: 0.2306*width, y: 1.00072*height))
        path.addLine(to: CGPoint(x: 0.78201*width, y: 0.63621*height))
        path.addLine(to: CGPoint(x: 0.78033*width, y: 0.63478*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.78244*width, y: 0.7041*height))
        path.addCurve(to: CGPoint(x: 0.78104*width, y: 0.70325*height), control1: CGPoint(x: 0.78236*width, y: 0.70357*height), control2: CGPoint(x: 0.78174*width, y: 0.70319*height))
        path.addLine(to: CGPoint(x: 0.76965*width, y: 0.70415*height))
        path.addCurve(to: CGPoint(x: 0.76852*width, y: 0.70519*height), control1: CGPoint(x: 0.76895*width, y: 0.7042*height), control2: CGPoint(x: 0.76844*width, y: 0.70467*height))
        path.addCurve(to: CGPoint(x: 0.76992*width, y: 0.70604*height), control1: CGPoint(x: 0.76859*width, y: 0.70572*height), control2: CGPoint(x: 0.76922*width, y: 0.7061*height))
        path.addLine(to: CGPoint(x: 0.78004*width, y: 0.70525*height))
        path.addLine(to: CGPoint(x: 0.7811*width, y: 0.71284*height))
        path.addCurve(to: CGPoint(x: 0.7825*width, y: 0.71369*height), control1: CGPoint(x: 0.78117*width, y: 0.71336*height), control2: CGPoint(x: 0.7818*width, y: 0.71374*height))
        path.addCurve(to: CGPoint(x: 0.78363*width, y: 0.71264*height), control1: CGPoint(x: 0.7832*width, y: 0.71363*height), control2: CGPoint(x: 0.7837*width, y: 0.71316*height))
        path.addLine(to: CGPoint(x: 0.78244*width, y: 0.7041*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.78018*width, y: 0.7036*height))
        path.addLine(to: CGPoint(x: 0.4607*width, y: 0.9994*height))
        path.addLine(to: CGPoint(x: 0.46268*width, y: 1.0006*height))
        path.addLine(to: CGPoint(x: 0.78216*width, y: 0.7048*height))
        path.addLine(to: CGPoint(x: 0.78018*width, y: 0.7036*height))
        path.closeSubpath()
        return path
    }
}
