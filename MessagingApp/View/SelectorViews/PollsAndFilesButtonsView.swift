//
//  PollsAndFilesButtonsView.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/4/25.
//

import SwiftUI

struct PollsAndFilesButtonsView: View {
    @State private var importing = false
    
    var body: some View {
        HStack {
            NavigationLink {
                Text("poll")
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal")
                    Text("Polls")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.buttonBackground)
                )
            }
            
            Button {
                importing = true
            } label: {
                HStack {
                    Image(systemName: "paperclip")
                    Text("Files")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.buttonBackground)
                )
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.content]) { result in
                switch result {
                case .success(let file):
                    print(file.absoluteString)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        .font(.subheadline)
        .bold()
        .padding()
    }
}
