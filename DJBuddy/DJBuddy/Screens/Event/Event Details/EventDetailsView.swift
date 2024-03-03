//
//  EventDetailsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import SwiftUI
import MapKit

struct EventDetailsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = EventDetailsViewModel()

    let event: EventData
    let isJoined: Bool
    @State private var isShareShowing = false

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text(event.name)
                    .font(.largeTitle)
                Text("by")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text(event.dj.username)
            }

            AddressRow(address: event.location)

            Map(position: .constant(MapCameraPosition.region(region))) {
                Marker(coordinate: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)) {
                    Label(event.name, systemImage: "headphones")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            .clipShape(.rect(cornerRadius: 12))
            .disabled(true)

            Text("Joined users: \(viewModel.numberOfJoined)")

            Spacer()

            buttonContent()
        }
        .foregroundStyle(.white)
        .padding(20)
        .backgroundColor(.background)
        .navBarWithTitle(title: "Event details", navigator: navigator, leadingButton: .back, trailingButton: .share($isShareShowing))
        .sheet(isPresented: $isShareShowing) {
            NavigationView {
                ShareEventView(code: event.code, isShowing: $isShareShowing)
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $viewModel.error)
        .onAppear {
            viewModel.isJoined = isJoined
            viewModel.getNumberOfJoined(to: event)
        }
        .animation(.default, value: viewModel.isJoined)
    }

    @ViewBuilder private func buttonContent() -> some View {
        VStack(spacing: 20) {
            if user.isDj {
                Button("Manage songs") {
                    navigator.navigate(to: .eventControl(event))
                }
                .buttonStyle(.largeProminent)

                Button("Delete event") {
                    // TODO: delete event
                }
                .buttonStyle(.largeSecondary)
            } else {
                if viewModel.isJoined {
                    Button("Request songs") {
                        navigator.navigate(to: .requestSong(event))
                    }
                    .buttonStyle(.largeProminent)

                    Button("Leave event") {
                        viewModel.leave(event: event, user: user)
                    }
                    .buttonStyle(.largeSecondary)
                } else {
                    Button("Join event") {
                        viewModel.join(event: event, user: user)
                    }
                    .buttonStyle(.largeProminent)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EventDetailsView(event: EventData.PreviewData, isJoined: true)
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
