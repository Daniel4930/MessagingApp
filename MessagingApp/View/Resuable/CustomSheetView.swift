//
//  CustomSheetView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/27/25.
//

import SwiftUI

struct CustomSheetView<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $isPresented) {
            sheetContent()
        }
    }
}
