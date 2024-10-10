//
//  ClassifiedLabelCard.swift
//  Visionale
//
//  Created by Kyrell Leano Siauw on 10/10/24.
//

import SwiftUI

struct ClassifiedLabelCard: View {
    @State var camera: Camera
    var body: some View {
        HStack{
            ForEach(camera.captureService.mlcLayer.predictionLabels, id: \.self){element in
                Text(element.description)
            }
        }
        .padding(8)
        .background(Material.thin)
        .cornerRadius(12)
    }
}

//#Preview {
//    ClassifiedLabelCard(camera: .constant(CameraModel()))
//}
