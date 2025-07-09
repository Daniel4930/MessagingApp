//
//  HomeView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                DirectMessageView()
            } label: {
                Text("Direct message view")
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
