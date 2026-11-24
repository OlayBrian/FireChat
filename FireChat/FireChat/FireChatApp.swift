//
//  FireChatApp.swift
//  FireChat
//
//  Created by Brian Ribeiro on 11/23/26.
//

import SwiftUI
import FirebaseCore

@main
struct FireChatApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
