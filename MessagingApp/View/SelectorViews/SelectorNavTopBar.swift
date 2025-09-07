//
//  SelectorNavTopBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI

struct SelectorNavTopBar: View {
    @Binding var height: CGFloat
    let minHeight: CGFloat
    let accessStatus: PhotoLibraryAccessStatus
    @ObservedObject var messageComposerViewModel: MessageComposerViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Button("Back") {
                height = minHeight
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if accessStatus == .fullAccess || accessStatus == .limitedAccess {
                VStack(spacing: 0) {
                    Text(messageComposerViewModel.selectionData.isEmpty ? "Recents" : "\(messageComposerViewModel.selectionData.count) selected")
                        .bold()
                        .font(.title2)
                    Text("Select up to 10")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            
            if accessStatus == .fullAccess {
                Button {
                    height = minHeight
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(14)
                        .foregroundStyle(.blue)
                }
            } else {
                CustomPhotoPickerView(accessStatus: accessStatus, height: $height, minHeight: minHeight, messageComposerViewModel: messageComposerViewModel) {
                    Text("All Albums")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(14)
                        .foregroundStyle(.blue)
                        .opacity(accessStatus != .limitedAccess ? 0.5 : 1.0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
