//
//  WelcomeFeature.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

import SwiftUI
import Combine
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
        
        enum Character: CaseIterable, Equatable {
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
    
    enum ObservedEvent {
        case path(NavigationDestination)
    }
}

@MainActor
final class WelcomeViewModel: ObservableObject {
    typealias Action = WelcomeFeature.Action
    typealias State = WelcomeFeature.State
    typealias ObservedEvent = WelcomeFeature.ObservedEvent
    
    private let continuation: AsyncStream<ObservedEvent>.Continuation
    let stream: AsyncStream<ObservedEvent>
    
    /// 캐릭터 정보
    @Published var characters: State.Character.AllCases
    
    private(set) var state = State()
    
    init() {
        let (stream, continuation) = AsyncStream<ObservedEvent>.makeStream()
        self.stream = stream
        self.continuation = continuation
        
        self.characters = State.Character.allCases
    }
    
    func send(action: Action.ViewAction) {
        send(action: .view(action))
    }
    
    private func send(action: Action) {
        switch action {
        case let .view(viewAction):
            switch viewAction {
            case let .characterTapped(character):
                break
            }
        }
    }
    
}

struct WelcomeView: View {
    typealias FeatureState = WelcomeFeature.State
    @Namespace var namespace
    
    /// 캐릭터 정보
    @State private var characters = FeatureState.Character.allCases
    
    var body: some View {
        HStack(spacing: 50) {
            ForEach(characters, id: \.self) { character in
                NavigationLink {
                    switch character {
                    case .male:
                        ChatFeature()
                            .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                        
                    case .female:
                        ChatFeature()
                            .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                        
                    case .fairy:
                        InAppPurchaseView()
                            .navigationTransition(.zoom(sourceID: character.displayText, in: namespace))
                    }
                } label: {
                    CardView(character.displayText)
                        .matchedTransitionSource(id: character.displayText, in: namespace)
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
            .background(.clear)
    }
}

#Preview {
    WelcomeView()
}

enum NavigationDestination: Hashable {
    case chat
    case inAppPurchase
}
