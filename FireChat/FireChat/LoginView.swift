//
//  LoginView.swift
//  FireChat
//
//  Created by Brian Ribeiro on 11/24/26.
//

import SwiftUI

struct LoginView: View {
    
    @Environment(AuthManager.self) var authManager // <-- Access the authManager from the environment

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            Text("Welcome!").font(.largeTitle)
            Text("App Created By Brian Ribeiro")
            Text("Z23638146")

            // Email + password fields
            VStack {
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
            }
            .textFieldStyle(.roundedBorder) // <-- Style text fields (applies to both text fields within the VStack)
            .textInputAutocapitalization(.never) // <-- No auto capitalization (can be annoying for emails and passwords)
            .padding(20)

            // Sign up + Login buttons
            HStack {
                Button("Sign Up") {
                    print("Sign up user: \(email), \(password)")
                    
                    authManager.signUp(email: email, password: password) // <-- Sign up user via authManager


                }
                .buttonStyle(.borderedProminent) // <-- Style button

                Button("Login") {
                    print("Login user: \(email), \(password)")
                    
                    authManager.signIn(email: email, password: password) // <-- Sign in user via authManager


                }
                .buttonStyle(.bordered) // <-- Style button
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager()) // <-- For the preview to work, pass an instance of AuthManager into the environment
}
