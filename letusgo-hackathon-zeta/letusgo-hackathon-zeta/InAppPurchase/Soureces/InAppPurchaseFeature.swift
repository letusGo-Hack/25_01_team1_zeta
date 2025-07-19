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

@MainActor
final class InAppPurchaseViewModel: ObservableObject {
    typealias PurchaseError = InAppPurchaseFeature.PurchaseError
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
    
    enum Action {
        case view(ViewAction)
        case purchaseResult(Result<Void, PurchaseError>)
        case alert(AlertAction)
        
        enum ViewAction {
            case buyButtonTapped
            case alert(AlertAction)
            
            enum AlertAction {
                case purchaseSuccess
                case purchaseFailure
            }
        }
        
        enum AlertAction {
            case showsPurchaseSuccess
            case showsPurchaseFailure
        }
    }
    
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
            
        case .purchaseFailure:
            state.purchaseAlert = nil
            
        }
    }

}

struct InAppPurchaseView: View {
    @StateObject private var viewModel = InAppPurchaseViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
        .modifier(PurchaseFailureAlertModifier(
            viewModel: viewModel,
            isPresented: $viewModel.purchaseFailureAlert,
            title: viewModel.state.purchaseAlert?.failure?.title ?? "",
            message: viewModel.state.purchaseAlert?.failure?.message ?? ""
        ))
        .modifier(PurchaseSuccessAlertModifier(
            viewModel: viewModel,
            isPresented: $viewModel.purchaseSuccessAlert,
            title: viewModel.state.purchaseAlert?.success?.title ?? "",
            message: viewModel.state.purchaseAlert?.success?.message ?? ""
        ))
        .task {
            for await event in viewModel.stream {
                switch event {
                case .dismiss:
                    dismiss()
                }
            }
        }
    }
     
    /// 인앱 결제 버튼
    private var BuyButton: some View {
        Button {
            viewModel.send(action: .buyButtonTapped)
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

extension InAppPurchaseView {
    struct PurchaseFailureAlertModifier: ViewModifier {
        let viewModel: InAppPurchaseViewModel
        @Binding var isPresented: Bool
        let title: String
        let message: String

        func body(content: Content) -> some View {
            content
                .alert(title, isPresented: $isPresented) {
                    Button("확인", role: .cancel) {
                        viewModel.send(action: .alert(.purchaseFailure))
                    }
                } message: {
                    Text(message)
                }
        }
    }
    
    struct PurchaseSuccessAlertModifier: ViewModifier {
        let viewModel: InAppPurchaseViewModel
        @Binding var isPresented: Bool
        let title: String
        let message: String

        func body(content: Content) -> some View {
            content
                .alert(title, isPresented: $isPresented) {
                    Button("확인", role: .cancel) {
                        viewModel.send(action: .alert(.purchaseSuccess))
                    }
                } message: {
                    Text(message)
                }
        }
    }
}
