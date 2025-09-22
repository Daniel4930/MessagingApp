//
//  FilePreviewView.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/20/25.
//

import SwiftUI
import QuickLook

struct FilePreviewView: UIViewControllerRepresentable {
    let fileURL: URL
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator

        // Add as child VC
        controller.addChild(previewController)
        previewController.view.frame = controller.view.bounds
        controller.view.addSubview(previewController.view)
        previewController.didMove(toParent: controller)

        // Add Done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(Coordinator.dismiss))
        previewController.navigationItem.rightBarButtonItem = doneButton

        // Embed in NavigationController to show button
        let navController = UINavigationController(rootViewController: previewController)
        return navController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(fileURL: fileURL, parent: self)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let fileURL: URL
        let parent: FilePreviewView

        init(fileURL: URL, parent: FilePreviewView) {
            self.fileURL = fileURL
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return fileURL as QLPreviewItem
        }

        @objc func dismiss() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

