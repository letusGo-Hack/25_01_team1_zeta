import Foundation
import FoundationModels

enum OndeviceAIFeature {
  /// LanguageModelSession에 요청을 하고 AI에게 응답을 받음
  static func languageModelSessionRespond(request: AISessionRequest) async throws -> String {
    let session = LanguageModelSession(instructions: request.instructions)
    let response = try await session.respond(to: request.prompt)
    return response.content
  }
}
