//
//  EmbededLinkLayoutView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/13/25.
//

import SwiftUI

struct EmbededLinkLayoutView: View {
    @Binding var embededTitle: String
    @Binding var embededDescription: String
    @Binding var embededImage: UIImage?
    @Binding var embededImageDimension: (width: CGFloat, height: CGFloat)
    @Binding var linkEmbededViewDimension: (width: CGFloat, height: CGFloat)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(embededTitle)
                .foregroundStyle(.blue)
                .padding(.bottom, embededDescription == "" ? 0 : 3)
            if embededDescription != "" {
                Text(embededDescription)
                    .font(.footnote)
            }
        }
        .frame(width: embededImage == nil ? linkEmbededViewDimension.width : linkEmbededViewDimension.width * 0.65, alignment: .leading)
        .padding([.vertical, .leading])
        if let embededImage = embededImage {
            Image(uiImage: embededImage)
                .resizable()
                .scaledToFit()
                .padding(3)
                .background(
                    GeometryReader { proxy in
                        Color.white
                            .onAppear {
                                embededImageDimension.width = proxy.size.width
                                embededImageDimension.height = proxy.size.height
                            }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }
    }
}
