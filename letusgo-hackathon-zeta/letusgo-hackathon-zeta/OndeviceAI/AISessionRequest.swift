import Foundation

struct AISessionRequest {
  /// AI Model이 가질 특징, 규칙
  let instructions: String
  /// AI가 답변할 프롬프트(예: 사용자의 질문)
  let prompt: String
}
