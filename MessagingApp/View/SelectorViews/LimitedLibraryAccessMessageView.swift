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
        HStack {
            Text("You've given us access to a select number of photos and videos.")
            
            Spacer()
            
            Button {
                presentLimitedLibraryPicker.toggle()
            } label: {
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
        .onChange(of: presentLimitedLibraryPicker) { _, isPresented in
            if !isPresented {
                refreshAssets()
            }
        }
        .task {
            getAssets()
        }
    }
}
