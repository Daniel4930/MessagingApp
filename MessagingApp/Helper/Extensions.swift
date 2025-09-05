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
    
    //Conditional modifier
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
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

// 4. Create an animation when triggers a tap gesture
struct TapGestureAnimation: ViewModifier {
    @State private var opacity: CGFloat = 1
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .simultaneousGesture(TapGesture().onEnded {
                withAnimation(.easeInOut(duration: 0.1)) {
                    opacity = 0.5
                }
                // Reset back to normal after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        opacity = 1
                    }
                }
            })
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
    
    func uploadFile(reference: StorageReference, fileUrl: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            uploadFileToBucket(reference: reference, url: fileUrl) { result in
                continuation.resume(with: result)
            }
        }
    }
}

// Helper to create a LastMessage from a Message
extension LastMessage {
    init?(from message: Message) {
        // A last message must have a timestamp. If not, fail initialization.
        guard let timestamp = message.date else {
            return nil
        }
        
        self.senderId = message.senderId
        self.timestamp = timestamp
        
        // Only set the text property if the message text is not nil and not empty.
        // Otherwise, it's nil, implying an attachment.
        if let text = message.text, !text.isEmpty {
            self.text = text
        } else if !message.photoUrls.isEmpty || !message.fileUrls.isEmpty {
            self.text = "Attachment"
        } else {
            self.text = nil
        }
    }
}
