//
//  ContentView.swift
//  WebrootAuth
//
//  Created by Mike Ross on 8/15/19.
//  Copyright © 2019 Mike Ross. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // Store our session auth manager here.
    @EnvironmentObject var userData: UserData

    var body: some View {
        Group {
            UserSignInView(userData: userData)
        }.onAppear()
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(userData)
    }
}
#endif
