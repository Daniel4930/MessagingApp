//
//  AppStateViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 10/27/25.
//

 import Foundation

final class AppStateViewModel: ObservableObject {
    @Published var previousScrollPositionId: [String:String] = [:]
}
