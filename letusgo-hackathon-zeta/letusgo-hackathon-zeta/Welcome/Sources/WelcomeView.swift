//
//  WelcomeFeature.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI
import Combine

struct WelcomeView: View {
    typealias FeatureState = WelcomeFeature.State
    @Namespace var namespace
    
    /// 캐릭터 정보
    @State private var characters = FeatureState.Character.allCases
    /// 결제 여부
    @AppStorage("hasPurchased") var hasPurchased: Bool = false
    
    var body: some View {
        HStack(spacing: 50) {
            ForEach(characters, id: \.self) { character in
                NavigationLink {
                    switch character {
                    case .male:
                        OnDeviceAIView(character: .male)
                            .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                        
                    case .female:
                        OnDeviceAIView(character: .female)
                            .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                        
                    case .fairy:
                        if hasPurchased {
                            OnDeviceAIView(character: .fairy)
                                .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                        } else {
                            InAppPurchaseView()
                                .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                        }
                        
                    }
                } label: {
                    CardView(character.displayText)
                        .matchedTransitionSource(id: character.displayText, in: namespace)
                        .background(.clear)
                }
            }
        }
        .ignoresSafeArea()
        .background {
            BackgroundBlurView
                .containerRelativeFrame(.horizontal)
                .containerRelativeFrame(.vertical)
        }
    }
    
    /// 카드 뷰
    private func CardView(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .padding()
            .scaledToFit()
            .background(.clear)
            .cornerRadius(20)
            .glassEffect()
            .clipShape(Circle())
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

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
