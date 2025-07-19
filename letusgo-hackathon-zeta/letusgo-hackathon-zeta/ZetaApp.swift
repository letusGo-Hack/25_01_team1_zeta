//
//  ZetaApp.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI

@main
struct ZetaApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            ChatFeature()
        }
    }
    
    init() {
        RevenueCatFeature.configure()
    }
}
