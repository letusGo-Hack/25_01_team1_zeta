//
//  WelcomeFeature.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI
import Combine

enum WelcomeFeature {
    
    enum Action {
        case view(ViewAction)
        
        enum ViewAction {
            case characterTapped(State.Character)
        }
    }
    
    struct State {
        var characters: [Character]?
        
        enum Character: CaseIterable {
            case male
            case female
            case fairy
            
            var displayText: String {
                switch self {
                case .male:
                    return "🙋‍♂️"
                case .female:
                    return "🙋‍♀️"
                case .fairy:
                    return "🧚"
                }
            }
        }
    }
}

@MainActor
final class WelcomeViewModel: ObservableObject {
    typealias Action = WelcomeFeature.Action
    typealias State = WelcomeFeature.State
    
    /// 캐릭터 정보
    @Published var characters = State.Character.allCases
    
    private(set) var state = State()
    
    func send(action: Action.ViewAction) {
        send(action: .view(action))
    }
    
    private func send(action: Action) {
        switch action {
        case let .view(viewAction):
            break
        }
    }
}

struct WelcomeView: View {
    @StateObject var viewModel = WelcomeViewModel()
    
    var body: some View {
        HStack(spacing: 50) {
            ForEach(viewModel.characters, id: \.self) { character in
                Button {
                    viewModel.send(action: .characterTapped(character))
                } label: {
                    CardView(character.displayText)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    /// 카드 뷰
    private func CardView(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .padding()
            .glassEffect()
            .scaledToFit()
    }
}

#Preview {
    WelcomeView()
}
