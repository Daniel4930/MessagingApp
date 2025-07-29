//
//  PhotoAndFileInfoView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI

struct PhotoAndFileInfoView: View {
    var body: some View {
        ScrollView {
            Image(systemName: "paperclip")
                .resizable()
                .scaledToFit()
                .padding(.vertical)
            
            LineIndicator(color: .white, width: 70, height: 3)
        }
        .padding()
        .background(Color.primaryBackground)
    }
}

//#Preview {
//    PhotoAndFileInfoView()
//}
