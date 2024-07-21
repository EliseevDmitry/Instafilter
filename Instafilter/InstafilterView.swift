//
//  InstafilterView.swift
//  Instafilter
//
//  Created by Dmitriy Eliseev on 17.07.2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI
//запрос отзыва о приложении в AppStore
import StoreKit

struct InstafilterView: View {
    
    //MARK: - PROPERTIES
    @AppStorage ("filtercount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    @State private var processedImage: Image?
    @State private var filterItensity = 0.5
    @State private var filterRadius = 250.0
    @State private var filterScale = 150.0
    @State private var selectedItem: PhotosPickerItem?
    @State private var curentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var beginImage: CIImage?
    @State private var showingFilters = false
    let context = CIContext()
    
    //MARK: - BODY
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                PhotosPicker(selection: $selectedItem){
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                Spacer()
                VStack {
                    HStack(){
                        Text("Intensity")
                            .frame(width: 80, alignment: .leading)
                            
                        Slider(value: $filterItensity)
                            .onChange(of: filterItensity, applyProcessing)
                    }
                    HStack{
                        Text("Radius")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: $filterRadius, in: 0...500, step: 25)
                            .onChange(of: filterRadius, applyProcessing)
                    }
                    HStack{
                        Text("Scale")
                            .frame(width: 80, alignment: .leading)
                        Slider(value: $filterScale, in: 0...300, step: 20)
                            .onChange(of: filterScale, applyProcessing)
                    }
                    HStack{
                        Button("Change Filter", action: changeFilter)
                        //.disabled(processedImage == nil ? true : false)
                        Spacer()
                        //share the picture
                        if let processedImage {
                            ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                        }
                    }
                }
                .disabled(processedImage == nil ? true : false)
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                //dialog here
                Button("Crystallize") {
                    setFilter(CIFilter.crystallize())
                }
                Button("Edges") {
                    setFilter(CIFilter.edges())
                }
                Button("Gaussin Blur ") {
                    setFilter(CIFilter.gaussianBlur())
                }
                Button("Pixellate") {
                    setFilter(CIFilter.pixellate())
                }
                Button("Sepia Tone") {
                    setFilter(CIFilter.sepiaTone())
                }
                Button("Unsharp Mask") {
                    setFilter(CIFilter.unsharpMask())
                }
                Button("Vignette") {
                    setFilter(CIFilter.vignette())
                }
                Button("SobelGradients") {
                    setFilter(CIFilter.sobelGradients())
                }
                Button("xRay") {
                    setFilter(CIFilter.xRay())
                }
                Button("ComicEffect") {
                    setFilter(CIFilter.comicEffect())
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    //MARK: -  FUNCTIONS
    func changeFilter(){
        showingFilters = true
    }
    
    func loadImage(){
        Task{
            if beginImage == nil {
                guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                guard let inputImage = UIImage(data: imageData) else { return }
                beginImage = CIImage(image: inputImage)
            }
            curentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing(){
        let inputKeys = curentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            curentFilter.setValue(filterItensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            curentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            curentFilter.setValue(filterScale, forKey: kCIInputScaleKey )
        }
        guard let outputImage = curentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    //X-Code - автоматически фиксит @MainActor
    @MainActor func setFilter(_ filter: CIFilter){
        curentFilter = filter
        loadImage()
        filterCount += 1
        if filterCount >= 2 {
            requestReview()
        }
    }
}

// Ошибка XCode при данной реализации:

//enum RangeFilter: Int {
//    case intensity
//    case radius
//    case scale
//    var range:ClosedRange<Int> {
//        switch self {
//        case .intensity : return 0...1
//        case .radius : return 0...500
//        case .scale : return 0...300
//        }
//    }
//}

//extension ClosedRange {
//    init<Other: Comparable>(_ other: ClosedRange<Other>, _ transform: (Other) -> Bound) {
//        self = transform(other.lowerBound)...transform(other.upperBound)
//    }
//}

//ClosedRange(RangeFilter.scale, Double.init)


//MARK: - PREVIEW
#Preview {
    InstafilterView()
}
