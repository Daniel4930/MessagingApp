
import Foundation

enum AlertType {
    case success
    case error
    case warning
    case info
}

struct AlertMessage: Identifiable, Equatable {
    let id = UUID()
    var message: String
    var type: AlertType
}
