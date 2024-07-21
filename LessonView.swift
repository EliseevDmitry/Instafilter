//
//  ContentView.swift
//  Instafilter
//
//  Created by Dmitriy Eliseev on 17.07.2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI



struct LessonView: View {
    @State private var image: Image?
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .rotationEffect(Angle(degrees: 90))
                .scaledToFit()
              
        }
        .onAppear(perform: loadImage)

    }
    func loadImage(){
       // image = Image(.car)
        let inputImage = UIImage(resource: .car)
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
        let currentFilter = CIFilter.sepiaTone()
        
       
        
        currentFilter.inputImage = beginImage
      //  currentFilter.intensity = 1
        
        //Начало - написания универсального фильтра под разные эффекты:
        let amount = 0.7
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(amount, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey) }
        //Конец - написания универсального фильтра под разные эффекты:
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImg = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImg)
        image = Image(uiImage: uiImage)
         
    }
}

#Preview {
    LessonView()
}
