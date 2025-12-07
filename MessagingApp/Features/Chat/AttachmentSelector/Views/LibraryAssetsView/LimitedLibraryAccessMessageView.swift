//
//  LimitedLibraryAccessMessageView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI

struct LimitedLibraryAccessMessageView: View {
    @State private var presentLimitedLibraryPicker = false
    let getAssets: () -> Void
    let refreshAssets: () -> Void
    
    var body: some View {
        contentView
    }
}

// MARK: View components
extension LimitedLibraryAccessMessageView {
    var contentView: some View {
        HStack {
            Text("You've given us access to a select number of photos and videos.")
            
            Spacer()
            
            manageButton
        }
        .onChange(of: presentLimitedLibraryPicker) { _, newValue in
            onChangeOfPresentLimitedLibraryPicker(isPresented: newValue)
        }
        .task {
            getAssets()
        }
    }
    
    var manageButton: some View {
        Button(action: manageButtonAction) {
            Text("Manage")
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.secondaryBackground)
                }
                .overlay {
                    LimitedLibraryPicker(isPresented: $presentLimitedLibraryPicker)
                }
        }
    }
}

// MARK: View actions
extension LimitedLibraryAccessMessageView {
    func manageButtonAction() {
        presentLimitedLibraryPicker.toggle()
    }
    
    func onChangeOfPresentLimitedLibraryPicker(isPresented: Bool) {
        if !isPresented {
            refreshAssets()
        }
    }
}
