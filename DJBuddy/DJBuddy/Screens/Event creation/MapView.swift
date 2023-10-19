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

    let address: AddressResult
    let completion: (AddressResult) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $viewModel.region) {
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

            Button("Select this location") {
                completion(address)
            }
            .buttonStyle(.largeProminent)
            .padding()
        }
    }
}

#Preview {
    MapView(address: AddressResult(title: "Title", subtitle: "Subtitle")) { _ in }
}
