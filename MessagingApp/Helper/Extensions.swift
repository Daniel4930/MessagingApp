//
//  Extensions.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/14/25.
//

import UIKit
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func applyPadding(_ padding: (edge: Edge.Set, value: CGFloat)?) -> some View {
        if let padding = padding {
            self.padding(padding.edge, padding.value)
        } else {
            self
        }
    }
    
    func customSheetModifier<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder sheetContent: @escaping () -> SheetContent) -> some View {
        modifier(CustomSheetView<SheetContent>(isPresented: isPresented, sheetContent: sheetContent))
    }
}

extension Image {
    func iconStyle(_ dimension: CGSize, borderColor: Color, borderWidth: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: dimension.width, height: dimension.height)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(borderColor, lineWidth: borderWidth)
            }
    }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
