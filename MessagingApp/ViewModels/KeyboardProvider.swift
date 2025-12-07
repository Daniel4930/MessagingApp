//
//  KeyboardProvider.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/24/25.
//

import Foundation
import UIKit

final class KeyboardProvider: ObservableObject {
    @Published var height: CGFloat = .zero
    @Published var keyboardWillAppear = false
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let height = UserDefaults.standard.float(forKey: "KeyboardHeight")
        if height == .zero {
            self.height = 346.0
        } else {
            self.height = CGFloat(height)
        }
    }
    
    @objc func keyboardWillHide() {
        keyboardWillAppear = false
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
        
        height = keyboardRect.height
        keyboardWillAppear = true
        
        let height = UserDefaults.standard.float(forKey: "KeyboardHeight")
        if height == .zero {
            UserDefaults.standard.set(Float(self.height), forKey: "KeyboardHeight")
        }
    }
}
