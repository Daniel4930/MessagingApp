//
//  MessageInputBar.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/10/25.fdsfsd
//

import SwiftUI

enum Field {
    case textEditor
}

struct MessageInputBar: View {
    @Binding var updateScrolling: Bool
    @Binding var showFileAndImageSelector: Bool
    @State private var message = ""
    @State private var showSendButton = false
    @FocusState private var focusedField: Field?
    
    let iconDimension: (width: CGFloat, height: CGFloat) = (25, 25)
    let paddingSpace: CGFloat = 10
    let animationDelay: Double = 0.05
    let rotationAngle: Double = 45.0
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button {
                    showFileAndImageSelector.toggle()
                    updateScrolling = true
                    hideKeyboard()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .rotationEffect(.degrees(showFileAndImageSelector ? rotationAngle : 0))
                        .frame(width: iconDimension.width, height: iconDimension.height)
                        .padding(paddingSpace)
                        .background(Color("SecondaryBackgroundColor"))
                        .clipShape(.circle)
                        .foregroundStyle(showFileAndImageSelector ? .blue : .white)
                        .animation(.easeInOut.delay(animationDelay), value: showFileAndImageSelector)
                }
                .rotationEffect(.degrees(0))
                
                ZStack(alignment: .leading) {
                    if message == "" {
                        Text("Message @Clyde")
                            .padding(.horizontal)
                            .foregroundStyle(.gray)
                    }
                    HStack {
                        TextEditor(text: $message)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: iconDimension.height)
                            .fixedSize(horizontal: false, vertical: true)
                            .onChange(of: message) { newMessage in
                                if newMessage != "" {
                                    showSendButton = true
                                } else {
                                    showSendButton = false
                                }
                            }
                            .focused($focusedField, equals: .textEditor)
                            .onChange(of: focusedField) { newValue in
                                if focusedField == .textEditor {
                                    showFileAndImageSelector = false
                                }
                            }
                    }
                    // Instead of using vertical padding (top & bottom),
                    // added it to the frame to prevent the TextEditor from resizing
                    .frame(
                        minHeight: iconDimension.height + (paddingSpace * 2),
                        maxHeight: UIScreen.main.bounds.height / 5
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, paddingSpace)
                    .onTapGesture {
                        updateScrolling = true
                    }
                }
                .background(Color("SecondaryBackgroundColor"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                if showSendButton {
                    Button {
                        
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .rotationEffect(Angle(degrees: 45))
                            .frame(width: iconDimension.width, height: iconDimension.height)
                            .padding(paddingSpace)
                            .background(.blue)
                            .clipShape(.circle)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onChange(of: message) { _ in
            updateScrolling = true
        }
    }
}
