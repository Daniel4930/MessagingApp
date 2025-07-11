//
//  DirectMessageNavBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.
//

import SwiftUI

struct DirectMessageNavBar: View {
    @Binding var message: String
    @Binding var navBarHeight: CGFloat
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (25, 25)
    let iconBackgroundColor = Color(cgColor: .init(red: 15/255, green: 15/255, blue: 15/255, alpha: 1))
    let paddingSpace: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: iconDimension.width, height: iconDimension.height)
                .padding(paddingSpace)
                .background(iconBackgroundColor)
                .clipShape(.circle)
                .foregroundStyle(.white)
            
            ZStack(alignment: .leading) {
                if message == "" {
                    Text("Message @Clyde")
                        .padding(.horizontal, 16)
                        .foregroundStyle(.gray)
                }
                HStack {
                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: iconDimension.height)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // Instead of using vertical padding (top & bottom),
                // added it to the frame to prevent the TextEditor from resizing
                .frame(
                    minHeight: iconDimension.height + (paddingSpace * 2),
                    maxHeight: UIScreen.main.bounds.height / 5
                )
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, paddingSpace)
            }
            .background(iconBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Image(systemName: "paperplane.fill")
                .resizable()
                .frame(width: iconDimension.width, height: iconDimension.height)
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        navBarHeight = proxy.size.height
                    }
                    .onChange(of: message) { newValue in
                        DispatchQueue.main.async {
                            navBarHeight = proxy.size.height
                        }
                    }
                
            }
        )
    }
}

#Preview {
    DirectMessageView()
}
