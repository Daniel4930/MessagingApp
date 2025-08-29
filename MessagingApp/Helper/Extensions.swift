//
//  Extensions.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/14/25.
//

import UIKit
import SwiftUI
import Kingfisher
import FirebaseStorage

// MARK: - View Extensions

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

// MARK: - Image Styling

// 1. Create a ViewModifier for the common parts of iconStyle
struct IconStyle: ViewModifier {
    let dimension: CGSize
    let borderColor: Color
    let borderWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: dimension.width, height: dimension.height)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(borderColor, lineWidth: borderWidth)
            }
    }
}

// 2. Create a ViewModifier for the common parts of sidebarItemStyle
struct SidebarItemStyle: ViewModifier {
    let dimension: CGSize
    let space: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: dimension.width, height: dimension.height)
            .padding(space)
    }
}

// 3. Create extensions for Image and KFImage to apply the styles
extension Image {
    func iconStyle(_ dimension: CGSize, borderColor: Color, borderWidth: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .modifier(IconStyle(dimension: dimension, borderColor: borderColor, borderWidth: borderWidth))
    }
    
    func sidebarItemStyle(dimension: CGSize, space: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .modifier(SidebarItemStyle(dimension: dimension, space: space))
    }
}

extension KFImage {
    func iconStyle(_ dimension: CGSize, borderColor: Color, borderWidth: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .modifier(IconStyle(dimension: dimension, borderColor: borderColor, borderWidth: borderWidth))
    }
    
    func sidebarItemStyle(dimension: CGSize, space: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .modifier(SidebarItemStyle(dimension: dimension, space: space))
    }
}

// MARK: - UINavigationController

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

// Helper extension to make the completion-handler based upload function usable with modern async/await.
extension FirebaseStorageService {
    func uploadData(reference: StorageReference, data: Data) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            uploadDataToBucket(reference: reference, data: data) { result in
                continuation.resume(with: result)
            }
        }
    }
}
