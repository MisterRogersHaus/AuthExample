//
//  AuthContainerViews.swift
//  WebrootAuth
//
//  Created by Mike Ross on 8/18/19.
//  Copyright © 2019 Mike Ross. All rights reserved.
//  These are the two auth container classes, SignUp and SignIn.
//

import Foundation
import SwiftUI

struct UserSignUpView : View {
    @ObservedObject var userData: UserData
    
    @Environment(\.presentationMode) var presentationMode

    @State var error    = false

    // This container func is calling our signUp func, in our AuthManager singleton. 
    func signUp () {
        error = false
        
        AuthManager.shared().signUp(userData.email, password: userData.password, completionHandler: {
            (result, reason) in
            // Guard against invalid results
            guard result == true else {
                self.error  = true
                if let msg = reason {
                    self.userData.message   = msg
                } else {
                    self.userData.message   = "Unknown error signing up."
                }
                // Might not be the best choice to nil out our data storage on error.
                self.userData.email      = ""
                self.userData.password   = ""
                return
            }
            // Successful signin, so set our message.
            self.userData.message    = "Successfully signed up \n"
            if let msg = reason {
                self.userData.message  += msg;
            }
            // We past our guard, so let's close this presentation
            self.presentationMode.value.dismiss()
        })
    }

    var body: some View {
        VStack {
            // Present our reusable embedded view
            UserAuthView(authModeText: "Create Account", userData: userData)
            // Error is set above when we attempt to create.
            if (error) {
                InplaceAlert(title: "Unable to Sign Up",
                             subtitle: self.userData.message).padding([.horizontal, .top])
            }
            // Present our signup button
            Button(action: signUp) {
                Text("Sign Up")
             }
            Button(action: { self.presentationMode.value.dismiss() }) {
                Text("Cancel")
            }

        }.padding()
        .frame(minWidth: 500)
    }
}

struct UserSignInView : View {
    @ObservedObject var userData: UserData

    @State var error = false
    @State var showSignUp = false
    @State var loggedIn = false;
    
    func signIn () {
        error = false
        AuthManager.shared().signIn(userData.email, password: userData.password, completionHandler: {
            (result, reason) in
            // Guard against invalid results
            guard result == true else {
                self.error  = true
                if let msg = reason {
                    self.userData.message    = msg
                } else {
                    self.userData.message    = "Unknown error signing in."
                }
                // Might not be the best choice to nil out our data storage on error.
                self.userData.email      = ""
                self.userData.password   = ""
                return
            }
            // Successful signin, so set our message.
            self.userData.message    = "Successfully logged in \n"
            if let msg = reason {
                self.userData.message    += msg;
            }
            // Set our status
            self.loggedIn = true;
        })
    }

    func signOut () {
        // For this quick and dirty, we're using Firebase json
        // Since there isn't a logout api, we'll similate logout by clearing our
        // auth fields and setting loggedIn to false
        userData.password   = ""
        userData.email      = ""
        userData.message    = "Successfully logged out"
        loggedIn            = false
    }
    
    var body: some View {
        VStack {
            // Present our reusable embedded view
            UserAuthView(authModeText: "Account Signin", userData: userData)
            // Error is set above when we attempt to create.
            if (error) {
                InplaceAlert(title: "Unable to Sign In", subtitle: "Are you sure an account exists for this email address? Is your password correct?").padding([.horizontal, .top])
            }

            Button(action: signIn) {
                    Text("Sign In")
             }
            .disabled(loggedIn)
            
            Button(action: signOut) {
                Text("Sign Out")
            }
            .disabled(loggedIn == false)

            // Setup a nav view so we can present our signup sheet
            NavigationView {
                
                VStack {
                    Button(action: { self.showSignUp.toggle() }) {
                        Text("Create an account?")
                    }.disabled(loggedIn)
                }.padding(.leading, 30)
            }
            .sheet(isPresented: $showSignUp, content: { UserSignUpView(userData: self.userData) })
            
            // A textfield for displaying our message
            Text(self.userData.message).lineLimit(nil).multilineTextAlignment(.leading)
        }
    }
}

#if DEBUG
struct Authenticate_Previews : PreviewProvider {
    
    static var previews: some View {
        UserSignInView(userData: UserData())
    }
}
#endif

