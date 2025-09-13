//
//  LimitedLibraryPicker.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/3/25.
//

import SwiftUI
import PhotosUI

struct LimitedLibraryPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        .init()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented, !context.coordinator.isPresented {
            Task {
                context.coordinator.isPresented = true
                await PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: uiViewController)
                context.coordinator.isPresented = false
                await MainActor.run {
                    isPresented = false
                }
            }
        }
        else if !isPresented, context.coordinator.isPresented {
            Task {
                await MainActor.run {
                    isPresented = true
                }
            }
        }
    }
    
    class Coordinator {
        var isPresented = false
    }
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
}
