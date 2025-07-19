import SwiftUI
import FoundationModels
import Foundation
import Combine

@MainActor
final class OnDeviceAIVM: ObservableObject {
  @Published private(set) var messages = [String]()
  
  func getAIResponse(prompt: String) {
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
  @StateObject private var vm = OnDeviceAIVM()
  
  @State private var messageText = ""
  
  var body: some View {
    Chat
  }
}

private extension OnDeviceAIView {
  var Chat: some View {
    VStack {
      // Header
      
      // Chat messages list
      ScrollView {
        VStack(spacing: 12) {
          ForEach(vm.messages, id: \.self) { message in
            HStack {
              if message.count % 2 == 0 { // Example for user\'s message
                Spacer()
                Text(LocalizedStringKey(message))
                  .padding(12)
                  .foregroundColor(.white)
                  .padding(.trailing)
                
              } else { // Example for other\'s message
                Text(LocalizedStringKey(message))
                  .padding(12)
                  .foregroundColor(.white)
                  .padding(.leading)
                
                Spacer()
              }
            }
          }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .contentTransition(.opacity)
      }
      .animation(.easeInOut, value: vm.messages)
      
      // 메시지 입력 필드
      HStack(spacing: 12) {
        TextField("Type a message...", text: $messageText)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .foregroundColor(.white)
          .accentColor(.white)
          .glassEffect()
        
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
      .padding()
    }
    .background( // 그라데이션 적용
      LinearGradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
    )
  }
}

#Preview {
  NavigationStack {
    OnDeviceAIView()
  }
}
