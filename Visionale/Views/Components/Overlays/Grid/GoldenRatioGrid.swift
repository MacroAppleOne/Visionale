//
//  GoldenRatioGrid.swift
//  Visionale
//
//  Created by Michelle Alvera Lolang on 17/10/24.
//

import SwiftUI

struct GoldenRatioGrid: View {
    var body: some View {
        GeometryReader { gr in
            let width = gr.size.width
            let height = width * 1.612
            
            Path { path in
                path.move(to: CGPoint(x: 0.9969*width, y: 0.002*height))
                path.addLine(to: CGPoint(x: 0.9969*width, y: 0.998*height))
                path.addCurve(to: CGPoint(x: 0.9937*width, y: height), control1: CGPoint(x: 0.9969*width, y: 0.9991*height), control2: CGPoint(x: 0.9955*width, y: height))
                path.addLine(to: CGPoint(x: 0.0032*width, y: height))
                path.addCurve(to: CGPoint(x: 0, y: 0.998*height), control1: CGPoint(x: 0.0014*width, y: height), control2: CGPoint(x: 0, y: 0.9991*height))
                path.addLine(to: CGPoint(x: 0, y: 0.002*height))
                path.addCurve(to: CGPoint(x: 0.0009*width, y: 0.0006*height), control1: CGPoint(x: 0, y: 0.0015*height), control2: CGPoint(x: 0.0003*width, y: 0.001*height))
                path.addCurve(to: CGPoint(x: 0.0032*width, y: 0), control1: CGPoint(x: 0.0015*width, y: 0.0002*height), control2: CGPoint(x: 0.0024*width, y: 0))
                path.addLine(to: CGPoint(x: 0.9937*width, y: 0))
                path.addCurve(to: CGPoint(x: 0.9969*width, y: 0.002*height), control1: CGPoint(x: 0.9955*width, y: 0), control2: CGPoint(x: 0.9969*width, y: 0.0009*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.9905*width, y: 0.002*height))
                path.addLine(to: CGPoint(x: 0.9937*width, y: 0.004*height))
                path.addLine(to: CGPoint(x: 0.0032*width, y: 0.004*height))
                path.addLine(to: CGPoint(x: 0.0064*width, y: 0.002*height))
                path.addLine(to: CGPoint(x: 0.0064*width, y: 0.998*height))
                path.addLine(to: CGPoint(x: 0.0032*width, y: 0.996*height))
                path.addLine(to: CGPoint(x: 0.9937*width, y: 0.996*height))
                path.addLine(to: CGPoint(x: 0.9905*width, y: 0.998*height))
                path.addLine(to: CGPoint(x: 0.9905*width, y: 0.002*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.9936*width, y: 0.5877*height))
                path.addCurve(to: CGPoint(x: 0.9932*width, y: 0.574*height), control1: CGPoint(x: 0.9936*width, y: 0.5831*height), control2: CGPoint(x: 0.9935*width, y: 0.5786*height))
                path.addCurve(to: CGPoint(x: 0.8503*width, y: 0.2895*height), control1: CGPoint(x: 0.9882*width, y: 0.4642*height), control2: CGPoint(x: 0.9225*width, y: 0.363*height))
                path.addCurve(to: CGPoint(x: 0.6086*width, y: 0.1282*height), control1: CGPoint(x: 0.7781*width, y: 0.2159*height), control2: CGPoint(x: 0.6993*width, y: 0.1699*height))
                path.addCurve(to: CGPoint(x: 0.3126*width, y: 0.0284*height), control1: CGPoint(x: 0.518*width, y: 0.0866*height), control2: CGPoint(x: 0.4152*width, y: 0.0491*height))
                path.addCurve(to: CGPoint(x: 0.0063*width, y: 0.0001*height), control1: CGPoint(x: 0.21*width, y: 0.0077*height), control2: CGPoint(x: 0.1078*width, y: 0.0039*height))
                path.addCurve(to: CGPoint(x: 0.006*width, y: 0.0001*height), control1: CGPoint(x: 0.0062*width, y: 0.0001*height), control2: CGPoint(x: 0.0061*width, y: 0.0001*height))
                path.addCurve(to: CGPoint(x: 0.0011*width, y: 0.0031*height), control1: CGPoint(x: 0.0033*width, y: 0.0001*height), control2: CGPoint(x: 0.0011*width, y: 0.0014*height))
                path.addCurve(to: CGPoint(x: 0.0057*width, y: 0.0062*height), control1: CGPoint(x: 0.0011*width, y: 0.0047*height), control2: CGPoint(x: 0.0031*width, y: 0.0061*height))
                path.addCurve(to: CGPoint(x: 0.3096*width, y: 0.0341*height), control1: CGPoint(x: 0.1074*width, y: 0.0099*height), control2: CGPoint(x: 0.2083*width, y: 0.0137*height))
                path.addCurve(to: CGPoint(x: 0.6028*width, y: 0.1331*height), control1: CGPoint(x: 0.4108*width, y: 0.0546*height), control2: CGPoint(x: 0.5127*width, y: 0.0917*height))
                path.addCurve(to: CGPoint(x: 0.842*width, y: 0.2927*height), control1: CGPoint(x: 0.6927*width, y: 0.1745*height), control2: CGPoint(x: 0.7706*width, y: 0.2199*height))
                path.addCurve(to: CGPoint(x: 0.9835*width, y: 0.5742*height), control1: CGPoint(x: 0.9135*width, y: 0.3656*height), control2: CGPoint(x: 0.9785*width, y: 0.4658*height))
                path.addCurve(to: CGPoint(x: 0.9838*width, y: 0.5877*height), control1: CGPoint(x: 0.9837*width, y: 0.5787*height), control2: CGPoint(x: 0.9838*width, y: 0.5832*height))
                path.addCurve(to: CGPoint(x: 0.8241*width, y: 0.8763*height), control1: CGPoint(x: 0.9838*width, y: 0.6923*height), control2: CGPoint(x: 0.9287*width, y: 0.8026*height))
                path.addCurve(to: CGPoint(x: 0.8011*width, y: 0.8914*height), control1: CGPoint(x: 0.8167*width, y: 0.8815*height), control2: CGPoint(x: 0.809*width, y: 0.8865*height))
                path.addCurve(to: CGPoint(x: 0.4143*width, y: 0.9936*height), control1: CGPoint(x: 0.6929*width, y: 0.958*height), control2: CGPoint(x: 0.5421*width, y: 0.9905*height))
                path.addCurve(to: CGPoint(x: 0.0959*width, y: 0.9127*height), control1: CGPoint(x: 0.2775*width, y: 0.9969*height), control2: CGPoint(x: 0.1676*width, y: 0.9663*height))
                path.addCurve(to: CGPoint(x: 0.0098*width, y: 0.7703*height), control1: CGPoint(x: 0.042*width, y: 0.8724*height), control2: CGPoint(x: 0.0098*width, y: 0.8191*height))
                path.addCurve(to: CGPoint(x: 0.021*width, y: 0.7235*height), control1: CGPoint(x: 0.0098*width, y: 0.754*height), control2: CGPoint(x: 0.0134*width, y: 0.7382*height))
                path.addCurve(to: CGPoint(x: 0.081*width, y: 0.664*height), control1: CGPoint(x: 0.0328*width, y: 0.7006*height), control2: CGPoint(x: 0.0545*width, y: 0.6804*height))
                path.addCurve(to: CGPoint(x: 0.2203*width, y: 0.6209*height), control1: CGPoint(x: 0.1223*width, y: 0.6386*height), control2: CGPoint(x: 0.175*width, y: 0.6229*height))
                path.addCurve(to: CGPoint(x: 0.3683*width, y: 0.6819*height), control1: CGPoint(x: 0.2945*width, y: 0.6178*height), control2: CGPoint(x: 0.3507*width, y: 0.6516*height))
                path.addCurve(to: CGPoint(x: 0.3748*width, y: 0.7043*height), control1: CGPoint(x: 0.3728*width, y: 0.6896*height), control2: CGPoint(x: 0.3748*width, y: 0.6972*height))
                path.addCurve(to: CGPoint(x: 0.3464*width, y: 0.7475*height), control1: CGPoint(x: 0.3748*width, y: 0.7226*height), control2: CGPoint(x: 0.3617*width, y: 0.7381*height))
                path.addLine(to: CGPoint(x: 0.3464*width, y: 0.7475*height))
                path.addCurve(to: CGPoint(x: 0.3418*width, y: 0.7501*height), control1: CGPoint(x: 0.3449*width, y: 0.7484*height), control2: CGPoint(x: 0.3434*width, y: 0.7493*height))
                path.addCurve(to: CGPoint(x: 0.2758*width, y: 0.7558*height), control1: CGPoint(x: 0.3191*width, y: 0.762*height), control2: CGPoint(x: 0.2937*width, y: 0.7604*height))
                path.addCurve(to: CGPoint(x: 0.2459*width, y: 0.7366*height), control1: CGPoint(x: 0.2582*width, y: 0.7513*height), control2: CGPoint(x: 0.2491*width, y: 0.744*height))
                path.addCurve(to: CGPoint(x: 0.2445*width, y: 0.7299*height), control1: CGPoint(x: 0.2449*width, y: 0.7344*height), control2: CGPoint(x: 0.2445*width, y: 0.7321*height))
                path.addCurve(to: CGPoint(x: 0.2508*width, y: 0.7167*height), control1: CGPoint(x: 0.2445*width, y: 0.7246*height), control2: CGPoint(x: 0.247*width, y: 0.7198*height))
                path.addLine(to: CGPoint(x: 0.2508*width, y: 0.7167*height))
                path.addCurve(to: CGPoint(x: 0.2526*width, y: 0.7154*height), control1: CGPoint(x: 0.2514*width, y: 0.7162*height), control2: CGPoint(x: 0.252*width, y: 0.7158*height))
                path.addCurve(to: CGPoint(x: 0.2701*width, y: 0.7121*height), control1: CGPoint(x: 0.2576*width, y: 0.7123*height), control2: CGPoint(x: 0.2643*width, y: 0.7115*height))
                path.addCurve(to: CGPoint(x: 0.2826*width, y: 0.7172*height), control1: CGPoint(x: 0.2768*width, y: 0.7127*height), control2: CGPoint(x: 0.2813*width, y: 0.7152*height))
                path.addCurve(to: CGPoint(x: 0.2831*width, y: 0.719*height), control1: CGPoint(x: 0.2829*width, y: 0.7178*height), control2: CGPoint(x: 0.2831*width, y: 0.7184*height))
                path.addCurve(to: CGPoint(x: 0.2809*width, y: 0.7224*height), control1: CGPoint(x: 0.2831*width, y: 0.7203*height), control2: CGPoint(x: 0.2822*width, y: 0.7216*height))
                path.addCurve(to: CGPoint(x: 0.2808*width, y: 0.7225*height), control1: CGPoint(x: 0.2809*width, y: 0.7224*height), control2: CGPoint(x: 0.2808*width, y: 0.7225*height))
                path.addLine(to: CGPoint(x: 0.2808*width, y: 0.7225*height))
                path.addCurve(to: CGPoint(x: 0.2722*width, y: 0.7237*height), control1: CGPoint(x: 0.2792*width, y: 0.7234*height), control2: CGPoint(x: 0.2769*width, y: 0.7236*height))
                path.addCurve(to: CGPoint(x: 0.2676*width, y: 0.7268*height), control1: CGPoint(x: 0.2696*width, y: 0.7238*height), control2: CGPoint(x: 0.2676*width, y: 0.7252*height))
                path.addCurve(to: CGPoint(x: 0.2676*width, y: 0.7269*height), control1: CGPoint(x: 0.2676*width, y: 0.7268*height), control2: CGPoint(x: 0.2676*width, y: 0.7269*height))
                path.addCurve(to: CGPoint(x: 0.2727*width, y: 0.7298*height), control1: CGPoint(x: 0.2677*width, y: 0.7286*height), control2: CGPoint(x: 0.27*width, y: 0.7299*height))
                path.addCurve(to: CGPoint(x: 0.2875*width, y: 0.7269*height), control1: CGPoint(x: 0.2766*width, y: 0.7297*height), control2: CGPoint(x: 0.2828*width, y: 0.7297*height))
                path.addCurve(to: CGPoint(x: 0.2878*width, y: 0.7268*height), control1: CGPoint(x: 0.2876*width, y: 0.7269*height), control2: CGPoint(x: 0.2877*width, y: 0.7268*height))
                path.addCurve(to: CGPoint(x: 0.2929*width, y: 0.7189*height), control1: CGPoint(x: 0.2908*width, y: 0.7249*height), control2: CGPoint(x: 0.2929*width, y: 0.7221*height))
                path.addCurve(to: CGPoint(x: 0.2917*width, y: 0.715*height), control1: CGPoint(x: 0.2929*width, y: 0.7176*height), control2: CGPoint(x: 0.2925*width, y: 0.7163*height))
                path.addCurve(to: CGPoint(x: 0.2717*width, y: 0.706*height), control1: CGPoint(x: 0.2888*width, y: 0.7105*height), control2: CGPoint(x: 0.281*width, y: 0.707*height))
                path.addCurve(to: CGPoint(x: 0.2457*width, y: 0.7111*height), control1: CGPoint(x: 0.2634*width, y: 0.7052*height), control2: CGPoint(x: 0.2533*width, y: 0.7064*height))
                path.addCurve(to: CGPoint(x: 0.243*width, y: 0.713*height), control1: CGPoint(x: 0.2448*width, y: 0.7117*height), control2: CGPoint(x: 0.2438*width, y: 0.7123*height))
                path.addLine(to: CGPoint(x: 0.243*width, y: 0.713*height))
                path.addCurve(to: CGPoint(x: 0.2347*width, y: 0.7299*height), control1: CGPoint(x: 0.2378*width, y: 0.7172*height), control2: CGPoint(x: 0.2347*width, y: 0.7234*height))
                path.addCurve(to: CGPoint(x: 0.2364*width, y: 0.7382*height), control1: CGPoint(x: 0.2347*width, y: 0.7326*height), control2: CGPoint(x: 0.2352*width, y: 0.7354*height))
                path.addCurve(to: CGPoint(x: 0.2721*width, y: 0.7615*height), control1: CGPoint(x: 0.2405*width, y: 0.7476*height), control2: CGPoint(x: 0.2519*width, y: 0.7563*height))
                path.addCurve(to: CGPoint(x: 0.3482*width, y: 0.7548*height), control1: CGPoint(x: 0.2921*width, y: 0.7666*height), control2: CGPoint(x: 0.3218*width, y: 0.7686*height))
                path.addCurve(to: CGPoint(x: 0.3533*width, y: 0.7518*height), control1: CGPoint(x: 0.3499*width, y: 0.7539*height), control2: CGPoint(x: 0.3516*width, y: 0.7529*height))
                path.addLine(to: CGPoint(x: 0.3533*width, y: 0.7518*height))
                path.addCurve(to: CGPoint(x: 0.3846*width, y: 0.7043*height), control1: CGPoint(x: 0.3703*width, y: 0.7414*height), control2: CGPoint(x: 0.3846*width, y: 0.7244*height))
                path.addCurve(to: CGPoint(x: 0.3775*width, y: 0.6798*height), control1: CGPoint(x: 0.3846*width, y: 0.6965*height), control2: CGPoint(x: 0.3825*width, y: 0.6883*height))
                path.addCurve(to: CGPoint(x: 0.2197*width, y: 0.6149*height), control1: CGPoint(x: 0.3588*width, y: 0.6476*height), control2: CGPoint(x: 0.2992*width, y: 0.6114*height))
                path.addCurve(to: CGPoint(x: 0.0742*width, y: 0.6597*height), control1: CGPoint(x: 0.1715*width, y: 0.6169*height), control2: CGPoint(x: 0.1167*width, y: 0.6335*height))
                path.addCurve(to: CGPoint(x: 0.0117*width, y: 0.7216*height), control1: CGPoint(x: 0.0466*width, y: 0.6766*height), control2: CGPoint(x: 0.0241*width, y: 0.6977*height))
                path.addCurve(to: CGPoint(x: 0, y: 0.7703*height), control1: CGPoint(x: 0.0037*width, y: 0.7369*height), control2: CGPoint(x: 0, y: 0.7534*height))
                path.addCurve(to: CGPoint(x: 0.0884*width, y: 0.9166*height), control1: CGPoint(x: 0, y: 0.8208*height), control2: CGPoint(x: 0.0333*width, y: 0.8754*height))
                path.addCurve(to: CGPoint(x: 0.4147*width, y: 0.9997*height), control1: CGPoint(x: 0.1622*width, y: 0.9718*height), control2: CGPoint(x: 0.2752*width, y: 1.003*height))
                path.addCurve(to: CGPoint(x: 0.808*width, y: 0.8957*height), control1: CGPoint(x: 0.5445*width, y: 0.9966*height), control2: CGPoint(x: 0.6978*width, y: 0.9635*height))
                path.addCurve(to: CGPoint(x: 0.8314*width, y: 0.8803*height), control1: CGPoint(x: 0.8161*width, y: 0.8907*height), control2: CGPoint(x: 0.8239*width, y: 0.8856*height))
                path.addCurve(to: CGPoint(x: 0.9936*width, y: 0.5877*height), control1: CGPoint(x: 0.938*width, y: 0.8053*height), control2: CGPoint(x: 0.9936*width, y: 0.6934*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.9941*width, y: 0.6169*height))
                path.addLine(to: CGPoint(x: 0.9942*width, y: 0.6169*height))
                path.addLine(to: CGPoint(x: 0.009*width, y: 0.6169*height))
                path.addCurve(to: CGPoint(x: 0.0058*width, y: 0.6149*height), control1: CGPoint(x: 0.0072*width, y: 0.6169*height), control2: CGPoint(x: 0.0058*width, y: 0.616*height))
                path.addCurve(to: CGPoint(x: 0.009*width, y: 0.613*height), control1: CGPoint(x: 0.0058*width, y: 0.6138*height), control2: CGPoint(x: 0.0072*width, y: 0.613*height))
                path.addLine(to: CGPoint(x: 0.9942*width, y: 0.613*height))
                path.addCurve(to: CGPoint(x: 0.9973*width, y: 0.6149*height), control1: CGPoint(x: 0.996*width, y: 0.613*height), control2: CGPoint(x: 0.9974*width, y: 0.6139*height))
                path.addCurve(to: CGPoint(x: 0.9941*width, y: 0.6169*height), control1: CGPoint(x: 0.9973*width, y: 0.616*height), control2: CGPoint(x: 0.9959*width, y: 0.6169*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.3814*width, y: 0.6167*height))
                path.addLine(to: CGPoint(x: 0.3845*width, y: 0.6148*height))
                path.addLine(to: CGPoint(x: 0.3845*width, y: 0.9979*height))
                path.addCurve(to: CGPoint(x: 0.3814*width, y: 0.9998*height), control1: CGPoint(x: 0.3845*width, y: 0.9989*height), control2: CGPoint(x: 0.3831*width, y: 0.9998*height))
                path.addCurve(to: CGPoint(x: 0.3782*width, y: 0.9979*height), control1: CGPoint(x: 0.3796*width, y: 0.9998*height), control2: CGPoint(x: 0.3782*width, y: 0.9989*height))
                path.addLine(to: CGPoint(x: 0.3782*width, y: 0.6148*height))
                path.addCurve(to: CGPoint(x: 0.3814*width, y: 0.6128*height), control1: CGPoint(x: 0.3782*width, y: 0.6137*height), control2: CGPoint(x: 0.3796*width, y: 0.6128*height))
                path.addCurve(to: CGPoint(x: 0.3845*width, y: 0.6148*height), control1: CGPoint(x: 0.3831*width, y: 0.6128*height), control2: CGPoint(x: 0.3845*width, y: 0.6137*height))
                path.addCurve(to: CGPoint(x: 0.3814*width, y: 0.6167*height), control1: CGPoint(x: 0.3845*width, y: 0.6159*height), control2: CGPoint(x: 0.3831*width, y: 0.6167*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.3779*width, y: 0.7659*height))
                path.addLine(to: CGPoint(x: 0.3779*width, y: 0.7659*height))
                path.addLine(to: CGPoint(x: 0.0084*width, y: 0.7659*height))
                path.addCurve(to: CGPoint(x: 0.0053*width, y: 0.7639*height), control1: CGPoint(x: 0.0067*width, y: 0.7659*height), control2: CGPoint(x: 0.0053*width, y: 0.765*height))
                path.addCurve(to: CGPoint(x: 0.0084*width, y: 0.7619*height), control1: CGPoint(x: 0.0053*width, y: 0.7628*height), control2: CGPoint(x: 0.0067*width, y: 0.7619*height))
                path.addLine(to: CGPoint(x: 0.3779*width, y: 0.7619*height))
                path.addCurve(to: CGPoint(x: 0.381*width, y: 0.7639*height), control1: CGPoint(x: 0.3796*width, y: 0.7619*height), control2: CGPoint(x: 0.3811*width, y: 0.7628*height))
                path.addCurve(to: CGPoint(x: 0.3779*width, y: 0.7659*height), control1: CGPoint(x: 0.381*width, y: 0.765*height), control2: CGPoint(x: 0.3796*width, y: 0.7659*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.2379*width, y: 0.6149*height))
                path.addCurve(to: CGPoint(x: 0.2348*width, y: 0.613*height), control1: CGPoint(x: 0.2379*width, y: 0.6138*height), control2: CGPoint(x: 0.2365*width, y: 0.613*height))
                path.addCurve(to: CGPoint(x: 0.2316*width, y: 0.6149*height), control1: CGPoint(x: 0.233*width, y: 0.613*height), control2: CGPoint(x: 0.2316*width, y: 0.6138*height))
                path.addLine(to: CGPoint(x: 0.2316*width, y: 0.7659*height))
                path.addLine(to: CGPoint(x: 0.2379*width, y: 0.7659*height))
                path.addLine(to: CGPoint(x: 0.2379*width, y: 0.7411*height))
                path.addLine(to: CGPoint(x: 0.2379*width, y: 0.6149*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.2348*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.2348*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.2348*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.2348*width, y: 0.7279*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.3784*width, y: 0.7063*height))
                path.addLine(to: CGPoint(x: 0.2348*width, y: 0.7063*height))
                path.addCurve(to: CGPoint(x: 0.2316*width, y: 0.7043*height), control1: CGPoint(x: 0.233*width, y: 0.7063*height), control2: CGPoint(x: 0.2316*width, y: 0.7054*height))
                path.addCurve(to: CGPoint(x: 0.2348*width, y: 0.7023*height), control1: CGPoint(x: 0.2316*width, y: 0.7032*height), control2: CGPoint(x: 0.233*width, y: 0.7023*height))
                path.addLine(to: CGPoint(x: 0.3784*width, y: 0.7023*height))
                path.addCurve(to: CGPoint(x: 0.3816*width, y: 0.7043*height), control1: CGPoint(x: 0.3802*width, y: 0.7023*height), control2: CGPoint(x: 0.3816*width, y: 0.7032*height))
                path.addCurve(to: CGPoint(x: 0.3784*width, y: 0.7063*height), control1: CGPoint(x: 0.3816*width, y: 0.7054*height), control2: CGPoint(x: 0.3802*width, y: 0.7063*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.2939*width, y: 0.7046*height))
                path.addCurve(to: CGPoint(x: 0.2907*width, y: 0.7027*height), control1: CGPoint(x: 0.2939*width, y: 0.7036*height), control2: CGPoint(x: 0.2925*width, y: 0.7027*height))
                path.addCurve(to: CGPoint(x: 0.2875*width, y: 0.7046*height), control1: CGPoint(x: 0.289*width, y: 0.7027*height), control2: CGPoint(x: 0.2875*width, y: 0.7036*height))
                path.addLine(to: CGPoint(x: 0.2875*width, y: 0.7111*height))
                path.addLine(to: CGPoint(x: 0.2875*width, y: 0.7659*height))
                path.addLine(to: CGPoint(x: 0.2939*width, y: 0.7659*height))
                path.addLine(to: CGPoint(x: 0.2939*width, y: 0.7047*height))
                path.addCurve(to: CGPoint(x: 0.2939*width, y: 0.7046*height), control1: CGPoint(x: 0.2939*width, y: 0.7047*height), control2: CGPoint(x: 0.2939*width, y: 0.7047*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.2934*width, y: 0.7299*height))
                path.addCurve(to: CGPoint(x: 0.2902*width, y: 0.7279*height), control1: CGPoint(x: 0.2934*width, y: 0.7288*height), control2: CGPoint(x: 0.292*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.279*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.2726*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.2316*width, y: 0.7279*height))
                path.addLine(to: CGPoint(x: 0.2316*width, y: 0.7318*height))
                path.addLine(to: CGPoint(x: 0.2902*width, y: 0.7318*height))
                path.addCurve(to: CGPoint(x: 0.2934*width, y: 0.7299*height), control1: CGPoint(x: 0.292*width, y: 0.7318*height), control2: CGPoint(x: 0.2934*width, y: 0.731*height))
                path.closeSubpath()
                path.move(to: CGPoint(x: 0.2758*width, y: 0.7063*height))
                path.addLine(to: CGPoint(x: 0.279*width, y: 0.7043*height))
                path.addLine(to: CGPoint(x: 0.279*width, y: 0.7298*height))
                path.addCurve(to: CGPoint(x: 0.2758*width, y: 0.7318*height), control1: CGPoint(x: 0.279*width, y: 0.7309*height), control2: CGPoint(x: 0.2776*width, y: 0.7318*height))
                path.addCurve(to: CGPoint(x: 0.2726*width, y: 0.7298*height), control1: CGPoint(x: 0.2741*width, y: 0.7318*height), control2: CGPoint(x: 0.2726*width, y: 0.7309*height))
                path.addLine(to: CGPoint(x: 0.2726*width, y: 0.7043*height))
                path.addCurve(to: CGPoint(x: 0.2736*width, y: 0.7029*height), control1: CGPoint(x: 0.2726*width, y: 0.7038*height), control2: CGPoint(x: 0.273*width, y: 0.7033*height))
                path.addCurve(to: CGPoint(x: 0.2758*width, y: 0.7023*height), control1: CGPoint(x: 0.2742*width, y: 0.7025*height), control2: CGPoint(x: 0.275*width, y: 0.7023*height))
                path.addCurve(to: CGPoint(x: 0.279*width, y: 0.7043*height), control1: CGPoint(x: 0.2776*width, y: 0.7023*height), control2: CGPoint(x: 0.279*width, y: 0.7032*height))
                path.addCurve(to: CGPoint(x: 0.2758*width, y: 0.7063*height), control1: CGPoint(x: 0.279*width, y: 0.7054*height), control2: CGPoint(x: 0.2776*width, y: 0.7063*height))
                path.closeSubpath()
            }
            .stroke(Color.white.opacity(0.33), lineWidth: 1)
            .aspectRatio(contentMode: .fit)
        }
    }
}

//struct MyIcon: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let width = rect.size.width
//        let height = rect.size.height
//        path.move(to: CGPoint(x: 0.9969*width, y: 0.002*height))
//        path.addLine(to: CGPoint(x: 0.9969*width, y: 0.998*height))
//        path.addCurve(to: CGPoint(x: 0.9937*width, y: height), control1: CGPoint(x: 0.9969*width, y: 0.9991*height), control2: CGPoint(x: 0.9955*width, y: height))
//        path.addLine(to: CGPoint(x: 0.0… control1: CGPoint(x: 0.0014*width, y: height), control2: CGPoint(x: 0, y: 0.9991*height))
//…        path.addCurve(to: CGPoint(x: 0.279*width, y: 0.7043*height), control1: CGPoint(x: 0.2776*width, y: 0.7023*height), control2: CGPoint(x: 0.279*width, y: 0.7032*height))
//        path.addCurve(to: CGPoint(x: 0.2758*width, y: 0.7063*height), control1: CGPoint(x: 0.279*width, y: 0.7054*height), control2: CGPoint(x: 0.2776*width, y: 0.7063*height))
//        path.closeSubpath()
//        return path
//    }
//}
//
//struct GoldenRatioGrid: View {
//    var imageName = "GoldenRatio"
//    @State private var aspectRatio: CGFloat = 1.612 // Aspect ratio of the image
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let height = geometry.size.height
//            let width = height * aspectRatio // Calculate width based on height and aspect ratio
//            
//            Image(imageName)
//                .resizable()
//                .aspectRatio(contentMode: .fit) // Maintain aspect ratio
//                .frame(width: width, height: height) // Set frame
//                .position(x: geometry.size.width / 2, y: height / 2) // Center horizontally
//                .onAppear {
//                    // Load the image and calculate the aspect ratio
//                    if let uiImage = UIImage(named: imageName) {
//                        aspectRatio = uiImage.size.width / uiImage.size.height
//                    }
//                }
//        }
//    }
//}

#Preview {
    GoldenRatioGrid()
}
