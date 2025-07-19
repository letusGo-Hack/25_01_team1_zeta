//
//  ZetaApp.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI
import Combine

class NavigationPathStore: ObservableObject {
    @Published var path: [NavigationDestination] = []
}

@main
struct ZetaApp: App {
    @StateObject private var navigationPathStore = NavigationPathStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPathStore.path) {
                WelcomeView()
                    .environmentObject(navigationPathStore)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .chat:
                    EmptyView()
                case .inAppPurchase:
                    InAppPurchaseView()
                        .environmentObject(navigationPathStore)
                }
            }
//            .environmentObject(navigationPathStore)
        }
        
    }
    
    init() {
//        RevenueCatFeature.configure()
    }
}

struct MyView: View {
    @State private var isNavigating = false

    var body: some View {
        NavigationView {
            VStack {
                Button("구매 화면으로 이동") {
                    isNavigating = true
                }

                // 숨겨진 NavigationLink (조건부 네비게이션용)
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
