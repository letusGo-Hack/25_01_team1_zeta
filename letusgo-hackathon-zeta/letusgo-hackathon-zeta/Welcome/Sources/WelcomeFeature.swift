//
//  WelcomeFeature 2.swift
//  letusgo-hackathon-zeta
//
//  Created by Geon Woo lee on 7/19/25.
//

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
    
}
