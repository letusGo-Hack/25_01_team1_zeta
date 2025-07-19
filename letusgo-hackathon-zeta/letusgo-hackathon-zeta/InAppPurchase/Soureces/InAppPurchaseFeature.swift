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
    
    /// 구매 에러
    enum PurchaseError: Error {
        case failedFetched
        case failedPurchase
    }
    
    /// 상태
    struct State {
        /// 구매 알럿
        var purchaseAlert: PurchaseAlert? = nil
        
        struct PurchaseAlert {
            var failure: Failure?
            var success: Success?
            
            struct Failure {
                var title: String
                var message: String
            }
            
            struct Success {
                var title: String
                var message: String
            }
        }
        
        func copy(
            purchaseAlert: PurchaseAlert? = nil
        ) -> State {
            State(
                purchaseAlert: purchaseAlert ?? self.purchaseAlert
            )
        }
    }
    
    enum ObservedEvent {
        case dismiss
    }
    
}


