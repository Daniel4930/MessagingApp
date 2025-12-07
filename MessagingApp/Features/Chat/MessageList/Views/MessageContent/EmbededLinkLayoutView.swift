//
//  EmbededLinkLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/13/25.
//

import SwiftUI

struct EmbededLinkLayoutView: View {
    let embededTitle: String
    let embededDescription: String
    let embededImage: UIImage?
    @Binding var embededImageDimension: CGSize
    
    var body: some View {
        VStack(alignment: .leading) {
            title
            
            description
        }
        .frame(maxWidth: .infinity)
        .padding([.vertical, .leading])
        
        image
    }
}

// MARK: View components
extension EmbededLinkLayoutView {
    var title: some View {
        Text(embededTitle)
            .foregroundStyle(.blue)
            .padding(.bottom, embededDescription == "" ? 0 : 3)
    }
    
    @ViewBuilder var description: some View {
        if embededDescription != "" {
            Text(embededDescription)
                .font(.footnote)
        }
    }
    
    @ViewBuilder var image: some View {
        if let embededImage = embededImage {
            Image(uiImage: embededImage)
                .resizable()
                .scaledToFit()
                .padding(3)
                .background(imageDimensionReader)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }
    }
    
    var imageDimensionReader: some View {
        GeometryReader { proxy in
            Color.white
                .onAppear {
                    embededImageDimension.width = proxy.size.width
                    embededImageDimension.height = proxy.size.height
                }
        }
    }
}
