import SwiftUI
import FoundationModels
import Foundation
import Combine

@MainActor
final class OnDeviceAIVM: ObservableObject {
  @Published private(set) var aiMessage = ""
  
  func getAIResponse() {
    Task {
      do {
        let instructions = """
          너는 연애 상담사야.
          사용자가 입력한 글을 읽고 나서 그 사람이 숨긴 의도나 감정을 파악해. 사용자의 고민 해결을 위한 사용자의 다음 행동을 추천해줘.
          말투는 심리 상담사처럼 따뜻하고 친절하게 말해줘. 
          3줄로 내용을 요약해줘.
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = "내가 좋아하는 사람에게 먼저 문자가 왔어. 만나자고 말해볼까?"
        let response = try await session.respond(to: prompt)
        aiMessage = response.content
      } catch {
        aiMessage = "Error: \(error)"
      }
    }
  }
}

struct OnDeviceAIView: View {
  @StateObject private var vm = OnDeviceAIVM()
  
  var body: some View {
    VStack {
      Text(LocalizedStringKey(vm.aiMessage))
        .contentTransition(.opacity)
    }
    .padding(20)
    .animation(.easeInOut, value: vm.aiMessage)
    .task {
      vm.getAIResponse()
    }
    .navigationTitle("Chat")
  }
}

#Preview {
  NavigationStack {
    OnDeviceAIView()
  }
}
