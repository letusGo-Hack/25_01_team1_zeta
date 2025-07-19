import SwiftUI
import FoundationModels
import Foundation
import Combine

@MainActor
final class OnDeviceAIVM: ObservableObject {
  @Published private(set) var messages = [String]()
  @Published private(set) var userMessages = [String]()
    
    enum Character {
        case male
        case female
        case fairy
    }
    
    private let character: Character
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
            너는 여성이고 연애 상담사야.
            사용자가 입력한 글을 읽고 나서 그 사람이 숨긴 의도나 감정을 파악해. 사용자의 고민 해결을 위한 사용자의 다음 행동을 추천해줘.
            말투는 따뜻하고 친절하게 말해줘. 그리고 여성이 말하는 것 같은 느낌으로 부탁해.
            3문장으로 내용을 요약해줘.
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
    .background( // 그라데이션 적용
      LinearGradient(
        colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .edgesIgnoringSafeArea(.all)
    )
  }
}

private extension OnDeviceAIView {
  var ChatMessages: some View {
    ScrollView {
      VStack(spacing: 12) {
        ForEach(vm.messages, id: \.self) { message in
          HStack {
            Text(LocalizedStringKey(message))
              .foregroundStyle(vm.userMessages.contains(message) ? .blue : .green)
              .frame(
                maxWidth: .infinity,
                alignment: vm.userMessages.contains(message) ?
                  .trailing : .leading
              )
              .padding(12)
              .glassEffect(in: RoundedRectangle(cornerRadius: 10))
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
      TextField("메시지를 입력하세요 ...", text: $messageText)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .foregroundColor(.white)
        .accentColor(.white)
        .glassEffect()
      
      SendButton
    }
  }
  
  var SendButton: some View {
    Button {
      vm.getAIResponse(prompt: messageText)
      messageText = ""
    } label: { // 입력 버튼
      Image(systemName: "arrow.up.circle.fill")
        .font(.title)
    }
    .glassEffect() // Liquid Glass 적용
    .disabled(messageText.isEmpty)
  }
}

#Preview {
  NavigationStack {
      OnDeviceAIView(character: .male)
  }
}
