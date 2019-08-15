//
//  ContentView.swift
//  WebrootAuth
//
//  Created by Mike Ross on 8/15/19.
//  Copyright © 2019 Mike Ross. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
