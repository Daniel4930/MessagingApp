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
    @Binding var embededImageDimension: (width: CGFloat, height: CGFloat)
    
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
        .frame(maxWidth: .infinity)
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
