//
//  PaymentResponse.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/11/2023.
//

import Foundation

struct PaymentResponse: Decodable {
    let paymentIntent: String
    let ephemeralKey: String
    let customer: String
    let publishableKey: String
}
