//
//  ImageGridModifiers.swift
//  MessagingApp
//
//  Created by Daniel Le on 11/29/25.
//

import SwiftUI
import Kingfisher

struct ImageGridSheetModifier<ImageView: View>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedIndex: Int
    let count: Int
    let content: (Int) -> ImageView

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                TabView(selection: $selectedIndex) {
                    ForEach(0..<count, id: \.self) { index in
                        self.content(index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
    }
}
