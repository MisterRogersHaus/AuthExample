//
//  InplaceAlert.swift
//  WebrootAuth
//
//  Created by Mike Ross on 8/16/19.
//  Copyright © 2019 Mike Ross. All rights reserved.
// Quick and dirty way to communicate error conditions inline
//

import SwiftUI

struct InplaceAlert: View {
    
    var title: String
    var subtitle: String?
    
    var body: some View {

        HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(.body)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)

                    if (self.subtitle != nil) {
                        Text(self.subtitle!)
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)

                    }

                }.padding(.leading)
            
            }
                .padding()
    }
}

#if DEBUG
struct InplaceAlert_Previews: PreviewProvider {
    static var previews: some View {
            InplaceAlert(
                title: "This is a test InplaceAlert",
                subtitle: "Now's the time to explain what went wrong, and provide the user with some useful direction as to how they should correct the issue."
            ).frame(height: 300)
        }
}
#endif
