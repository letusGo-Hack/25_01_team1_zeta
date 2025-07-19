//
//  InAppPurchaseViewModel.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI
import Combine
import StoreKit
import RevenueCat
import RevenueCatUI

@MainActor
final class InAppPurchaseViewModel: ObservableObject {
    typealias PurchaseError = InAppPurchaseFeature.PurchaseError
    typealias Action = InAppPurchaseFeature.Action
    typealias State = InAppPurchaseFeature.State
    typealias ObservedEvent = InAppPurchaseFeature.ObservedEvent
    
    private let continuation: AsyncStream<ObservedEvent>.Continuation
    let stream: AsyncStream<ObservedEvent>
    
    /// 에러 알림
    @Published var purchaseFailureAlert: Bool
    /// 성공 알림
    @Published var purchaseSuccessAlert: Bool
    
    init() {
        let (stream, continuation) = AsyncStream<ObservedEvent>.makeStream()
        self.stream = stream
        self.continuation = continuation
        
        self.purchaseFailureAlert = false
        self.purchaseSuccessAlert  = false
    }
    
    /// 상태
    private(set) var state = State()
    
    func send(action: Action.ViewAction) {
        send(action: .view(action))
    }
    
    private func send(action: Action) {
        switch action {
        case let .view(viewAction):
            switch viewAction {
            case .buyButtonTapped:
                handleBuyButtonTapped()
                
            case let .alert(alertAction):
                handleAlertAction(action: alertAction)
            }
        
        case let .purchaseResult(result):
            switch result {
            case .success:
                handlePurchaseSucceeded()
                
            case .failure(let failure):
                handlePurchaseFailed(error: failure)
            }
            
        case let .alert(alertAction):
            switch alertAction {
            case .showsPurchaseSuccess:
                purchaseSuccessAlert.toggle()
                
            case .showsPurchaseFailure:
                purchaseFailureAlert.toggle()
                
            }
        }
    }
    
    private func handleBuyButtonTapped() {
        Task {
            let product = InAppPurchaseFeature.Product.nonConsumable.productID
            let fetchedProducts = await Purchases.shared.products([product])
            
            guard let product = fetchedProducts.first else {
                send(action: .purchaseResult(.failure(.failedFetched)))
                return
            }
            
            do {
                _ = try await Purchases.shared.purchase(product: product)
            } catch {
                send(action: .purchaseResult(.failure(.failedPurchase)))
            }
        }
    }
    
    private func handlePurchaseSucceeded() {
        var purchaseAlert: State.PurchaseAlert = .init()
        purchaseAlert.success = .init(
            title: "구매 완료",
            message: "영구 아이템 구매 완료"
        )
        
        state.purchaseAlert = purchaseAlert
        
        send(action: .alert(.showsPurchaseSuccess))
    }
    
    private func handlePurchaseFailed(error: PurchaseError) {
        var purchaseAlert: State.PurchaseAlert = .init()
        purchaseAlert.failure = .init(
            title: "구매 실패",
            message: error.localizedDescription
        )

        state.purchaseAlert = purchaseAlert
        
        send(action: .alert(.showsPurchaseFailure))
    }
    
    private func handleAlertAction(action: Action.ViewAction.AlertAction) {
        switch action {
        case .purchaseSuccess:
            state.purchaseAlert = nil
            continuation.yield(.dismiss)
            
        case .purchaseFailure:
            state.purchaseAlert = nil
            
        }
    }

}
