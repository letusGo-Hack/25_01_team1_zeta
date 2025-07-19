import SwiftUI
import FoundationModels
import Foundation
import Combine

@MainActor
final class OnDeviceAIVM: ObservableObject {
  @Published private(set) var messages = [String]()
  @Published private(set) var userMessages = [String]()
    
    enum Character: String {
        case male = "남성"
        case female = "여성"
        case fairy
    }
    
    private(set) var character: Character
    init(character: Character) {
        self.character = character
    }
    
  func getAIResponse(prompt: String) {
    userMessages.append(prompt)
    messages.append(prompt)
    
    Task {
      do {
        let request = AISessionRequest(
          instructions: """
            너는 \(character.rawValue)이고 연애 상담사야.
            사용자의 숨긴 의도나 감정을 파악해. 사용자의 고민 해결을 위한 사용자의 다음 행동을 추천해줘.
            그리고 따뜻하고 친절한, \(character.rawValue)이 말하는 것 같은 느낌으로 부탁해.
            한 문장, 150 글자 이내로 내용을 요약해줘.
          """,
          prompt: prompt
        )
        let content = try await OndeviceAIFeature.languageModelSessionRespond(request: request)
        messages.append(content)
      } catch {
        print("Error: \(error)")
        messages.append("죄송합니다. 하신 말씀을 잘 이해하지 못했습니다.😓\n다시 입력해주세요.")
      }
    }
  }
}

struct OnDeviceAIView: View {
    @StateObject private var vm: OnDeviceAIVM

    init(character: OnDeviceAIVM.Character) {
        _vm = StateObject(wrappedValue: OnDeviceAIVM(character: character))
    }
    
  @State private var messageText = ""
  
  var body: some View {
    VStack(spacing: 10) {
      ChatMessages
      
      InputField
        .padding()
    }
    .background {
        BackgroundBlurView
    }
  }
}

private extension OnDeviceAIView {
  var ChatMessages: some View {
    ScrollView {
      VStack(spacing: 12) {
        ForEach(vm.messages, id: \.self) { message in
          HStack {
            Text(LocalizedStringKey(message))
              .foregroundStyle(
                vm.userMessages.contains(message) ? .black : .black.opacity(0.6)
              )
              .frame(
                maxWidth: .infinity,
                alignment: vm.userMessages.contains(message) ?
                  .trailing : .leading
              )
              .padding(12)
              .glassEffect(
                .regular.tint(
                  .white.opacity(vm.userMessages.contains(message) ? 0.5 : 0.8)
                ).interactive(),
                in: RoundedRectangle(cornerRadius: 10)
              )
          }
        }
      }
      .padding(.horizontal)
      .padding(.top, 8)
      .contentTransition(.opacity)
    }
    .animation(.easeInOut, value: vm.messages)
    
  }
  
  var InputField: some View {
    HStack(spacing: 12) {
      TextField("그 사람, 나한테 관심 있을까?", text: $messageText)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .foregroundColor(.black)
        .accentColor(.black)
        .glassEffect(.regular.tint(.white.opacity(0.3)).interactive())
      
      SendButton
    }
  }
  
  var SendButton: some View {
    Button {
      vm.getAIResponse(prompt: messageText)
      messageText = ""
    } label: { // 입력 버튼
      Image(systemName: "paperplane.fill")
        .font(.body)
        .padding(12)
        .glassEffect()
    }
    .glassEffect(.regular.tint(.purple.opacity(0.3)).interactive())
    .disabled(messageText.isEmpty)
  }
    
    /// 배경
    private var BackgroundBlurView: some View {
        VStack {
            switch vm.character {
            case .female:
                Color.pink.opacity(0.5)
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .overlay(Color.black.opacity(0.2)) // 어두운 느낌 추가 (선택)
            case .male:
                Color.blue.opacity(0.5)
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .overlay(Color.black.opacity(0.2)) // 어두운 느낌 추가 (선택)
            case .fairy:
                Color.green.opacity(0.5)
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .overlay(Color.black.opacity(0.2)) // 어두운 느낌 추가 (선택)
            }
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
  NavigationStack {
      OnDeviceAIView(character: .male)
  }
}
