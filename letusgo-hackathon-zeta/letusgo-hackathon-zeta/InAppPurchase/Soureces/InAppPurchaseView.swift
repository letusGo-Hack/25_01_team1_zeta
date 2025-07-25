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
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
//                .frame(height: 48)
            
            HStack {
                Text("LLM 기반 감정 이해")
                    .font(.system(size: 24, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 12)
            
            HStack {
                Image(.foundationmodel)
                    .resizable()
                    .frame(width: 256 / 3, height: 256 / 3)
                
                Text(
                    """
                    LLM 모델을 활용해 실제 연애 상담처럼 깊이 있는 조언과 공감을 전달합니다.
                    """
                )
            }
            
//            Spacer()
//                .frame(height: 48)
            
            HStack {
                Text("Apple Intelligence 연동")
                    .font(.system(size: 24, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 12)
            
            HStack {
                Image(.appleIntelligence)
                    .resizable()
                    .frame(width: 256 / 3, height: 256 / 3)
                
                Text(
                """
                애플 인텔리전스를 통해 사용자의 상황에 맞춘 정교하고 개인화된 대화를 제공합니다.
                """
                )
            }
            
//            Spacer()
//                .frame(height: 48)
            
            HStack {
                Text("요정 연애 코치")
                    .font(.system(size: 24, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 12)
            
            HStack {
                Text("🧚")
                    .font(.system(size: 256 / 4)) // 원하는 크기로 조절
                    .frame(width: 256 / 3, height: 256 / 3)
                
                Text(
                    """
                    당신의 마음을 이해하고 애플 인텔리전스와 AI가 함께하는 따뜻하고 스마트한 연애 코칭 요정입니다.
                    """
                )
            }
            
            Spacer()
            
            BuyButton
                .padding(.bottom, 24)
        }
        .padding(.horizontal, 12)
        .navigationTitle("RevenueCatSDK")
        .navigationBarTitleDisplayMode(.inline)
        .background {
            BackgroundBlurView
        }
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
        }
    }
    
    /// 배경
    private var BackgroundBlurView: some View {
        VStack {
            Image(.wwdc25)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .frame(width: 1000, height: 1000, alignment: .center)
                .clipped()
                .blur(radius: 10)
                .overlay(Color.black.opacity(0.2)) // 어두운 느낌 추가 (선택)
            
            Spacer()
        }
//        .ignoresSafeArea()
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
