//
//  ButtonType.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

enum ButtonType {
    case back
    case menu(() -> Void)
    case options
    case profile(String)
    case close(Binding<Bool>)
}
