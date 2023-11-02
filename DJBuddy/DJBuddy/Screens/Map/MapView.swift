//
//  MapView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel: MapViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $viewModel.region) {
                ForEach(viewModel.annotationItems) { event in
                    Annotation("", coordinate: event.location.coordinate) {
                        EventAnnotation(event: event)
                    }
                }
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .all))
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapScaleView()
            }
            .mapControlVisibility(.visible)
            .edgesIgnoringSafeArea(.bottom)

            Button {
                viewModel.getEvents()
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                .padding(12)
                .background(.thickMaterial)
                .clipShape(.rect(cornerRadius: 12))
            }
            .padding(8)
            .padding(.top, 40)
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    MapView(viewModel: MapViewModel())
}
