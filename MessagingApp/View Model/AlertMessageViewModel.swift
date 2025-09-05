
import Foundation
import SwiftUI

class AlertMessageViewModel: ObservableObject {
    @Published var alertMessage: AlertMessage? = nil
    @Published var showAlert: Bool = false
    
    private var alertQueue: [AlertMessage] = []
    
    func presentAlert(message: String, type: AlertType) {
        let newAlert = AlertMessage(message: message, type: type)
        alertQueue.append(newAlert)
        
        if !showAlert {
            showAlert = true
            alertMessage = alertQueue.removeFirst()
        }
    }
    
    func dismissAlert() {
        if !alertQueue.isEmpty {
            alertMessage = alertQueue.removeFirst()
        } else {
            showAlert = false
            alertMessage = nil
        }
    }
}
