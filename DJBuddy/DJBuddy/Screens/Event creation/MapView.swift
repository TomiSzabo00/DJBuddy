//
//  MapView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()

    private let address: AddressResult

    init(address: AddressResult) {
        self.address = address
    }

    var body: some View {
        Map {
            ForEach(viewModel.annotationItems) { item in
                Marker("", coordinate: item.coordinate)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .all))
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapControlVisibility(.visible)
        .onAppear {
            self.viewModel.getPlace(from: address)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MapView(address: AddressResult(title: "Title", subtitle: "Subtitle"))
}
