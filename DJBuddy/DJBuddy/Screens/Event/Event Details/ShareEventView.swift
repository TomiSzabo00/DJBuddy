//
//  ShareEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ShareEventView: View {
    let code: String

    @Binding var isShowing: Bool

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(code.uppercased())
                .font(.largeTitle)

            Spacer()

            Image(uiImage: generateQRCode(from: code.uppercased()))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 250, height: 250)
                )

            Spacer()
            Spacer()
        }
        .padding(20)
        .foregroundStyle(.white)
        .backgroundColor(.background)
        .navBarWithTitle(title: "Share event", navigator: Navigator(), trailingButton: .close($isShowing))
    }

    private func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    ShareEventView(code: "AAAA - AAAA - AAAA", isShowing: .constant(true))
}
