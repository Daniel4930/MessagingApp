//
//  ChangeOnlineStatusView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/3/25.
//

import SwiftUI

struct ChangeOnlineStatusView: View {
    @State private var selectedItem: OnlineStatus
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    static let onlineStatus: [OnlineStatus] = [
        .online, .idle, .doNotDisturb, .invisible
    ]
    
    init(selectedItem: OnlineStatus) {
        self.selectedItem = selectedItem
    }
    
    var body: some View {
        VStack {
            Text("Change Online Status")
                .font(.headline)
            
            Form {
                onlineStatusPickerView
            }
        }
        .padding(.top)
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                await updateStatus(newStatus: newValue)
            }
        }
    }
}

// MARK: - View components
extension ChangeOnlineStatusView {
    var onlineStatusPickerView: some View {
        Picker("Online Status", selection: $selectedItem) {
            pickerItem
        }
        .pickerStyle(.inline)
    }
    
    var pickerItem: some View {
        ForEach(ChangeOnlineStatusView.onlineStatus, id: \.self) { status in
            HStack {
                OnlineStatusCircle(
                    status: status.rawValue,
                    color: .secondaryBackground,
                    outterDimension: CGSize(width: 20, height: 20),
                    innerDimension: CGSize(width: 15, height: 15)
                )
                Text(formatOnlineStatusString(status: status.rawValue))
            }
            .tag(status)
        }
    }
}

// MARK: - View actions
extension ChangeOnlineStatusView {
    func updateStatus(newStatus: OnlineStatus) async {
        await userViewModel.updateOnlineStatus(status: newStatus)
        dismiss()
    }
    
    func formatOnlineStatusString(status: String) -> String {
        let withSpaces = status.unicodeScalars.reduce("") { result, scalar in
            if CharacterSet.uppercaseLetters.contains(scalar) {
                return result + " " + String(scalar)
            } else {
                return result + String(scalar)
            }
        }
        
        return withSpaces.trimmingCharacters(in: .whitespaces).capitalized
    }
}
