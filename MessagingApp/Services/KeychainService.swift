
import Foundation
import KeychainAccess

struct KeychainService {
    static let shared = KeychainService()
    
    // Using a unique service identifier is a good practice.
    private let keychain = Keychain(service: "com.DanielLe.MessagingApp")

    private let lastEmailKey = "lastLoggedInEmail"

    func save(email: String, password: String) {
        // Save password to keychain
        do {
            try keychain.set(password, key: email)
            // Save email to UserDefaults to know who was the last user
            UserDefaults.standard.set(email, forKey: lastEmailKey)
        } catch {
            print("Error saving to keychain: \(error)")
        }
    }

    func load() -> (email: String, password: String)? {
        guard let email = UserDefaults.standard.string(forKey: lastEmailKey) else {
            return nil
        }

        do {
            guard let password = try keychain.get(email) else {
                return nil
            }
            return (email, password)
        } catch {
            print("Error loading from keychain: \(error)")
            return nil
        }
    }

    func clear(email: String) {
        do {
            try keychain.remove(email)
            UserDefaults.standard.removeObject(forKey: lastEmailKey)
        } catch {
            print("Error clearing from keychain: \(error)")
        }
    }
}
