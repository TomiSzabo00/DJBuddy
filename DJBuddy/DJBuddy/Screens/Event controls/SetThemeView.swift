//
//  SetThemeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SetThemeView: View {
    let event: EventData
    let completion: (SongTheme) -> Void
    let cancel: () -> Void

    @State private var selectedTheme: SongTheme = .pop

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set theme for \(event.name) in \(event.location.title)")
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(SongTheme.allCases, id: \.hashValue) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
            } label: {
                pickerLabel(for: selectedTheme)
            }

            Spacer()

            Button("Set theme") {
                completion(selectedTheme)
            }
            .buttonStyle(.largeProminent)

            Button("Cancel") {
                cancel()
            }
            .buttonStyle(.largeSecondary)
        }
        .foregroundStyle(.white)
        .padding()
        .backgroundColor(.asset.background)
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private func pickerLabel(for theme: SongTheme) -> some View {
        HStack {
            Text(theme.displayName)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "arrowtriangle.down.fill")
        }
        .padding()
        .foregroundStyle(.gray)
        .backgroundColor(.white)
        .frame(maxHeight: 60)
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    SetThemeView(event: EventData.PreviewData) { _ in } cancel: {}
}
