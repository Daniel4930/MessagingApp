//
//  FirebaseDatabaseService.swift
//  MessagingApp
//
//  Created by Daniel Le on 8/16/25.
//

import FirebaseDatabase

class FirebaseDatabaseService {
    static let shared = FirebaseDatabaseService()
    let ref = Database.database().reference()
    
    func addUser() {
        ref.child("users").child(UUID().uuidString).setValue(["username": "unlimited"])
    }
}
