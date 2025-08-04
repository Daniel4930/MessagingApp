//
//  ImagePickerView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/28/25.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct ImagePickerView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ imagePickerView: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: ImagePickerView
        
        init(picker: ImagePickerView) {
            self.picker = picker
        }
    }
}
