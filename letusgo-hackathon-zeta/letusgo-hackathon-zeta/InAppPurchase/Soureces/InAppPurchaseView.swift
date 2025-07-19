//
//  InAppPurchaseView.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI

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

fileprivate extension InAppPurchaseView {
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

#Preview {
    NavigationStack {
        InAppPurchaseView()
    }
}
