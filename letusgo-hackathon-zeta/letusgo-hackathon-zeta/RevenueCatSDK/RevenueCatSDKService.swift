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

enum RevenueCatFeature {
    /// 앱 시작시에 한번만 호출
    static func configure() {
        Purchases.logLevel = .verbose
        Purchases.proxyURL = RevenueCatFeature.proxyURL.flatMap { URL(string: $0) }
        Purchases.configure(withAPIKey: RevenueCatFeature.apiKey)
    }
    
    private static let apiKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String ?? ""
    }()

    private static let proxyURL: String? = {
        guard
            var scheme = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_PROXY_URL_SCHEME") as? String,
            !scheme.isEmpty,
            let host = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_PROXY_URL_HOST") as? String,
            !host.isEmpty else {
            return nil
        }
        if !scheme.hasSuffix(":") {
            scheme.append(":")
        }
        return "\(scheme)//\(host)"
    }()
}

public struct RContentView: View {
    @State private var presentCustomerCenter = false
    @State private var pushCustomerCenter = false

    @State private var manageSubscriptions = false
    @State private var actionSheetIsPresented = false

    @State private var productToBuy: String?

    public init() { }

    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Button("Present Customer Center") {
                    presentCustomerCenter = true
                }
                .buttonStyle(.borderedProminent)

                Button("Push Customer Center") {
                    pushCustomerCenter = true
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .navigationDestination(isPresented: $pushCustomerCenter, destination: {
                CustomerCenterView(
                    navigationOptions: .init(
                        usesNavigationStack: true,
                        usesExistingNavigation: true,
                        shouldShowCloseButton: false
                    )
                )
            })
            .ignoresSafeArea(.all)
            .presentCustomerCenter(isPresented: $presentCustomerCenter)
            .manageSubscriptionsSheet(isPresented: $manageSubscriptions)
            .confirmationDialog(
                "Buy something",
                isPresented: $actionSheetIsPresented
            ) {
                buttonsView
            }
            .safeAreaInset(edge: .bottom, content: {
                HStack {
                    Button("Buy something") {
                        actionSheetIsPresented = true
                    }
                    .buttonStyle(.bordered)

                    Button("Manage subscriptions") {
                        manageSubscriptions = true
                    }
                    .buttonStyle(.bordered)
                }
            })
        }
    }

    @ViewBuilder
    var buttonsView: some View {
        ForEach(Self.products, id: \.self) { product in
            Button {
                productToBuy = product

                Task {
                    let fetchedProducts = await Purchases.shared.products([product])
                    guard let product = fetchedProducts.first else {
                        print("⚠️ Failed to find product: \(product)")
                        await MainActor.run {
                            productToBuy = nil
                        }
                        return
                    }

                    do {
                        _ = try await Purchases.shared.purchase(product: product)
                    } catch {
                        print("⚠️ Purchase failed: \(error)")
                    }

                    await MainActor.run {
                        productToBuy = nil
                    }
                }
            } label: {
                Text("Buy \(product)")
            }
        }
    }

    static var products: [String] {
         [
             "maestro.weekly.tests.01",
             "maestro.monthly.tests.02",
             "maestro.weekly2.tests.01",
             "maestro.nonconsumable.tests.01",
             "maestro.consumable.tests.01"
         ]
     }
}

#Preview {
    RContentView()
}
