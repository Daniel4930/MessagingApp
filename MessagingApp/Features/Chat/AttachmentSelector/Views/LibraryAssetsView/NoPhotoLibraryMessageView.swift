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
            photoSymbol
            
            noAccessToPhotoLibraryMessage
            
            navigateToSetting
        }
        .font(.caption)
    }
}

// MARK: View components
extension NoPhotoLibraryMessageView {
    var photoSymbol: some View {
        Image(systemName: "photo.stack")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .padding(.bottom)
    }
    
    var noAccessToPhotoLibraryMessage: some View {
        Text("Enable permissions to access your photo library.")
            .multilineTextAlignment(.center)
    }
    
    var navigateToSetting: some View {
        Button(action: buttonAction) {
            Text("Enable in Settings")
                .padding(10)
                .background(.blue)
        }
    }
}

// MARK: View actions
extension NoPhotoLibraryMessageView {
    func buttonAction() {
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        }
    }
}
