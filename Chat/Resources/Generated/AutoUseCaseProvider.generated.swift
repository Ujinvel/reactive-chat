// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


protocol HasChatUseCase {
var chat: ChatUseCase { get }
}

typealias UseCases =
HasChatUseCase

protocol UseCasesProvider: UseCases {}
