//
//  PhotoPickerView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/11/2023.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @EnvironmentObject var user: UserData

    @Binding var isShowing: Bool

    @StateObject var viewModel = PhotoPickerViewModel()
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(alignment: .topTrailing) {
                        CircleButton(radius: 20, background: .white.opacity(0.8)) {
                            viewModel.selectedImage = nil
                            selectedItem = nil
                        } label: {
                            Image(systemName: "multiply")
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                        }
                        .padding(30)

                    }
            } else {
                Text("No image selected")
                    .frame(height: 300, alignment: .center)
            }

            PhotosPicker(selection: $selectedItem) {
                Text("Select image")
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(.red)
                    .clipShape(.rect(cornerRadius: 12))
            }

            Button("Upload image") {
                viewModel.uploadImage(user: user) { result in
                    switch result {
                    case .success():
                        isShowing = false
                    case .failure(let failure):
                        viewModel.error = failure
                    }
                }
            }
            .buttonStyle(.largeSecondary)
            .disabled(viewModel.selectedImage == nil)
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.selectedImage = uiImage
                        return
                    }
                }

                print("Failed")
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $viewModel.error)
        .foregroundStyle(.white)
        .padding()
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Select new image", leadingButton: .close($isShowing))
    }
}

#Preview {
    PhotoPickerView(isShowing: .constant(true))
        .environmentObject(UserData.EmptyUser)
}
