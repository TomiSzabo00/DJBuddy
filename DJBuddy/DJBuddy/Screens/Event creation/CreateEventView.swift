//
//  CreateEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct CreateEventView: View {
    @State var isPresent = false
    var body: some View {
        Button("select place") {
            isPresent.toggle()
        }
        .sheet(isPresented: $isPresent) {
            PlacesViewControllerBridge(onPlaceSelected: {
                place in
//                tempLocation =  place.name ?? "Please select your location"
//                selectedGMSPlace = place
//                isCsLocationError = false
            })
        }
    }
}

#Preview {
    CreateEventView()
}
