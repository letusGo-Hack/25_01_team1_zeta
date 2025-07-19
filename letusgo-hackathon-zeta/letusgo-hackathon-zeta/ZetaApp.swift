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

struct MyView: View {
    @State private var isNavigating = false

    var body: some View {
        NavigationStack {
            VStack {
                Button("구매 화면으로 이동") {
                    isNavigating = true
                }

                NavigationLink(
                    destination: InAppPurchaseView(),
                    isActive: $isNavigating
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("메인 화면")
        }
    }
}
