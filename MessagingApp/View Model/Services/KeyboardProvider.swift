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
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
        
        height = keyboardRect.height
    }
}
