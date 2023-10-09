//
//  DJHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct DJHomeView: View {
    var body: some View {
        EventList {
            EventListTile()
            EventListTile()
        }
    }
}

#Preview {
    DJHomeView()
}
