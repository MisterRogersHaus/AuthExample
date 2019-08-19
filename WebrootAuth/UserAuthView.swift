//
//  UserAuthView.swift
//  WebrootAuth
//
//  Created by Mike Ross on 8/15/19.
//  Copyright © 2019 Mike Ross. All rights reserved.
//
// For decomposing, we're using a view / container pattern.
// This UserAuthView is fairly simple and is used for both signin and signup

import Foundation
import SwiftUI

struct UserAuthView : View {
    let authModeText: String

    @ObservedObject var userData: UserData

    var body: some View {
        VStack {
            // Render our auth fields, using the mode text that was supplied.
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            Text(authModeText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            TextField("Email:", text: $userData.email)
                .padding()
            SecureField("Password:", text: $userData.password)
                .padding()
        }.padding()
    }
}

