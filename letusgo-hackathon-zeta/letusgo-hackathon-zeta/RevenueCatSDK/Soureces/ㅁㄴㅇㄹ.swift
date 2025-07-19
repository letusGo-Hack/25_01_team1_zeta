//
//  RevenueCatSDKFeature.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import RevenueCat
import RevenueCatUI
import SwiftUI
import StoreKit
import Combine

final class InAppPurchaseViewModel: ObservableObject {
    
    enum Action {
        
    }
    
    func send(action: Action) {
        
    }
}

public struct InAppPurchaseView {
    @StateObject private var viewModel = InAppPurchaseViewModel()
    
    var body: some View {
        Text("Hello, World!")
        
        
    }
}


