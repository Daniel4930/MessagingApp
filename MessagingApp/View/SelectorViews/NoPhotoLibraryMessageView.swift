//
//  NoPhotoLibraryMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI

struct NoPhotoLibraryMessageView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "photo.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.bottom)
            
            Text("Enable permissions to access your photo library.")
                .multilineTextAlignment(.center)
            Button {
                if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingUrl)
                }
            } label: {
                Text("Enable in Settings")
                    .padding(10)
                    .background(.blue)
            }
        }
        .font(.caption)
    }
}
