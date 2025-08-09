//
//  CameraView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/28/25.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct CameraView: UIViewControllerRepresentable {
    let refreshAssets: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        imagePicker.allowsEditing = false
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ imagePickerView: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(picker: CameraView) {
            self.parent = picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            if let uiImage = info[.originalImage] as? UIImage {
                UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
            }
        }
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
            let coordinator = Unmanaged<Coordinator>.fromOpaque(contextInfo).takeUnretainedValue()
            coordinator.parent.refreshAssets()
        }
    }
}
