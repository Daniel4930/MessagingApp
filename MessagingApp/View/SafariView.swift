//
//  SafariView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/13/25.
//
import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url : URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> some UIViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<SafariView>) {}
}
