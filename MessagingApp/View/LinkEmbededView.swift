//
//  LinkEmbededView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/13/25.
//

import SwiftUI

struct LinkEmbededView: View {
    @Binding var embededTitle: String
    @Binding var embededDescription: String
    @Binding var embededImage: UIImage?
    @Binding var embededImageDimension: (width: CGFloat, height: CGFloat)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(embededTitle)
                .foregroundStyle(.blue)
                .padding(.bottom, 3)
            Text(embededDescription)
                .font(.footnote)
        }
        .padding([.vertical, .leading])
        if let embededImage = embededImage {
            Image(uiImage: embededImage)
                .resizable()
                .scaledToFit()
                .padding(5)
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
