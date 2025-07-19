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
        
//        struct PurchaseErrorAlert {
//            var title: String
//            var message: String
//        }
        
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
    }
}

final class InAppPurchaseViewModel: ObservableObject {
    typealias PurchaseError = InAppPurchaseFeature.PurchaseError
    typealias State = InAppPurchaseFeature.State
    
    /// 에러 알림
    @Published var purchaseErrorAlert: Bool = false
//    /// 에러 알림
//    @Published var purchaseErrorAlert: Bool = false
    
    /// 상태
    private var state = State()
    
    enum Action {
        case view(ViewAction)
        case purchaseResult(Result<Void, PurchaseError>)
        case alert(AlertAction)
        
        enum ViewAction {
            case buyButtonTapped
        }
        
        enum AlertAction {
            case showsPurchaseSuccess
            case showsPurchaseFailure
        }
    }
    
    func send(action: Action) {
        switch action {
        case let .view(viewAction):
            switch viewAction {
            case .buyButtonTapped:
                purchaseErrorAlert.toggle()
                handleBuyButtonTapped()
            }
        
        case let .purchaseResult(result):
            switch result {
            case .success:
                handlePurchaseSucceeded()
                
            case .failure(let failure):
                handelPurchaseFailed(error: failure)
            }
            
        case let .alert(alertAction):
            switch alertAction {
            case .showsPurchaseSuccess:
                purchaseErrorAlert.toggle()
                
            case .showsPurchaseFailure:
                purchaseErrorAlert.toggle()
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
        state.purchaseAlert?.success = .init(
            title: "구매 완료",
            message: "영구 아이템 구매 완료"
        )

        send(action: .alert(.showsPurchaseSuccess))
    }
    
    private func handelPurchaseFailed(error: PurchaseError) {
        state.purchaseAlert?.failure = .init(
            title: "구매 실패",
            message: error.localizedDescription
        )

        send(action: .alert(.showsPurchaseFailure))
    }
}

struct InAppPurchaseView: View {
    @StateObject private var viewModel = InAppPurchaseViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            Image(.foundationmodel)
                .resizable()
                .frame(width: 256, height: 256)
            Spacer()
            
            BuyButton
            
        }
        .background {
            BackgroundBlurView
        }
        .navigationTitle("RevenueCatSDK")
        .alert("경고", isPresented: $viewModel.purchaseErrorAlert) {
            Button("확인", role: .cancel) { }
            Button("삭제", role: .destructive) {
                print("삭제됨")
            }
        } message: {
            Text("정말 삭제하시겠습니까?")
        }
    }
    
    /// 인앱 결제 버튼
    private var BuyButton: some View {
        Button {
            viewModel.send(action: .view(.buyButtonTapped))
        } label: {
            Text("구매하기")
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .glassEffect()
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
    }
    
    /// 배경
    private var BackgroundBlurView: some View {
        VStack {
            Image(.foundationmodel)
                .resizable()
                .scaledToFill()
                .frame(width: 1000, height: 1000, alignment: .center)
                .clipped()
                .blur(radius: 30)
                .overlay(Color.black.opacity(0.2)) // 어두운 느낌 추가 (선택)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        InAppPurchaseView()
    }
}
