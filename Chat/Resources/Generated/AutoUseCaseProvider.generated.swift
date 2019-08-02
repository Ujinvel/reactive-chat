// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


protocol HasChatUseCase {
var chat: ChatUseCase { get }
}

typealias UseCases =
HasChatUseCase

protocol UseCasesProvider: UseCases {}
