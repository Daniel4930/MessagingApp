//
//  ImageAttachmentView.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/29/25.
//

import SwiftUI

struct ImageAttachmentView: View {
    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
