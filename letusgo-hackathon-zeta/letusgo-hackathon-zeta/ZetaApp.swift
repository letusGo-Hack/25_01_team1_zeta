//
//  ZetaApp.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI
import Combine

@main
struct ZetaApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WelcomeView()
            }
        }
    }
    
    init() {
//        RevenueCatFeature.configure()
    }
}
