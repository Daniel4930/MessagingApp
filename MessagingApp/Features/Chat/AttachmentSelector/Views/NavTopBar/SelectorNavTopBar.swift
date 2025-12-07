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
            backButton
            
            Spacer()
            
            fullAndLimitedAccess()
            
            rightTopBarButton()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: View computed properties
extension SelectorNavTopBar {
    var numberOfSelectedAttachment: String {
        if messageComposerViewModel.selectionData.isEmpty {
            return "Recents" // 0 selected
        }
        return "\(messageComposerViewModel.selectionData.count) selected"
    }
}

// MARK: View components
extension SelectorNavTopBar {
    var backButton: some View {
        Button("Back") {
            backButtonAction()
        }
        .foregroundStyle(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var selectedAmountView: some View {
        VStack(spacing: 0) {
            Text(numberOfSelectedAttachment)
                .bold()
                .font(.title2)
            Text("Select up to 10")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var doneButton: some View {
        Button(action: doneButtonAction) {
            Text("Done")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(14)
                .foregroundStyle(.blue)
        }
    }
    
    var allAlbumsButton: some View {
        Text("All Albums")
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(14)
            .foregroundStyle(.blue)
    }
    
    func fullAndLimitedAccess() -> some View {
        if accessStatus == .fullAccess || accessStatus == .limitedAccess {
            return AnyView(
                Group {
                    selectedAmountView
                    
                    Spacer()
                }
            )
        }
        return AnyView(EmptyView())
    }
    
    func rightTopBarButton() -> some View {
        if accessStatus == .denied || accessStatus == .restricted || accessStatus == .undetermined || accessStatus == .limitedAccess {
            return AnyView(doneButton)
        } else {
            return AnyView(
                CustomPhotoPickerView(height: $height, minHeight: minHeight, messageComposerViewModel: messageComposerViewModel) {
                    allAlbumsButton
                }
            )
        }
    }
}

// MARK: View actions
extension SelectorNavTopBar {
    func backButtonAction() {
        withAnimation(.smooth(duration: 0.3)) {
            height = minHeight
        }
    }
    
    func doneButtonAction() {
        height = minHeight
    }
}
