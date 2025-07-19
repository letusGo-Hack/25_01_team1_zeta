import SwiftUI

struct ChatFeature: View {
    @State private var messageText: String = ""
    @State private var messages: [String] = ["Hello!", "How are you?", "This is a glassmorphism chat UI."]

    var body: some View {
        VStack {
            // Header

            // Chat messages list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages, id: \.self) { message in
                        HStack {
                            if message.count % 2 == 0 { // Example for user\'s message
                                Spacer()
                                Text(message)
                                    .padding(12)
                                    .foregroundColor(.white)
                                    .padding(.trailing)
                                
                            } else { // Example for other\'s message
                                Text(message)
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
            }

            // 메시지 입력 필드
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .glassEffect()


                Button(action: sendMessage) { // 입력 버튼
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
//                        .foregroundColor(.blue)
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

    func sendMessage() {
        if !messageText.isEmpty {
            messages.append(messageText)
            messageText = ""
        }
    }
}

#Preview {
    ChatFeature()
}
