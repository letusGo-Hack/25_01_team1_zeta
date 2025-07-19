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

enum InAppPurchaseFeature {
    
    /// 상품
    enum Product: CaseIterable {
        case weekly
        case monthly
        case weekly2
        case nonConsumable
        case consumable
        
        /// 상품 아이디
        var productID: String {
            switch self {
            case .weekly:
                return "maestro.weekly.tests.01"
            case .monthly:
                return "maestro.monthly.tests.02"
            case .weekly2:
                return "maestro.weekly2.tests.01"
            case .nonConsumable:
                return "maestro.nonconsumable.tests.01"
            case .consumable:
                return "maestro.consumable.tests.01"
            }
        }
        
        /// UI에 표시되는 이름
        var displayName: String {
            switch self {
            case .weekly: return "주간 구독"
            case .monthly: return "월간 구독"
            case .weekly2: return "주간 구독2"
            case .nonConsumable: return "영구 상품"
            case .consumable: return "소모성 상품"
            }
        }
    }
}

final class InAppPurchaseViewModel: ObservableObject {
    
    /// 상품정보
    @Published var products = InAppPurchaseFeature.Product.allCases
    
    enum Action {
        case view(ViewAction)
        
        enum ViewAction {
            case buyButtonTapped
        }
    }
    
    func send(action: Action) {
        switch action {
        case let .view(viewAction):
            switch viewAction {
            case .buyButtonTapped:
                handleBuyButtonTapped()
            }
        }
    }
    
    private func handleBuyButtonTapped() {
        Task {
            let product = InAppPurchaseFeature.Product.nonConsumable.productID
            let fetchedProducts = await Purchases.shared.products([product])
            
            guard let product = fetchedProducts.first else {
                // handle error
                return
            }
            
            do {
                _ = try await Purchases.shared.purchase(product: product)
            } catch {
                // handle error
            }
        }
    }
}

struct InAppPurchaseView: View {
    @StateObject private var viewModel = InAppPurchaseViewModel()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            BuyButton
        }
        .navigationTitle("인앱결제")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// 인앱 결제 버튼
    private var BuyButton: some View {
        Button {
            viewModel.send(action: .view(.buyButtonTapped))
        } label: {
            Text("구매하기")
        }
        .padding()
        .containerRelativeFrame(.horizontal)
        .glassEffect()
    }
}

#Preview {
    NavigationStack {
        InAppPurchaseView()
    }
}
