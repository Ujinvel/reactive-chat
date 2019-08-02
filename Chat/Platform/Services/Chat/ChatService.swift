//
//  ChatService.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import ReactiveSwift

final class ChatService: ChatUseCase {
    private let contex: ServiceContext
    
    // MARK: - Life cycle
    init(context: ServiceContext) {
        self.contex = context
    }
    
    // MARK: - Data source
    func makeMessagesDataSource() -> AnyChatDataSource<Message> {
        return AnyChatDataSource(ChatDataSource(observationBuilder: makeMessageObservationBuilder(),
                                                sectionBlockBuilder: makeMessageSectionBlockBuilder(),
                                                toDomain: Message.init,
                                                toPlatform: makeToPlatformMapper()))
    }
    
    private func makeMessageObservationBuilder() -> ChatDataSource<Message, RMMessage>.ObservationBuilder {
        return { RMMessage.getMessages(from: $0) }
    }
    
    private func makeMessageSectionBlockBuilder() -> ChatDataSource<Message, RMMessage>.SectionBlockBuilder {
        return { RMMessage.getMessages(for: $1, from: $0) }
    }
    
    private func makeToPlatformMapper() -> ChatDataSource<Message, RMMessage>.TransformToPlatform {
        return { RMMessage.getById($0.localId, from: $1) }
    }
    
    // MARK: - Sent
    func sent(message: Message) -> TriggerResult {
        return AsyncTaskResult(value: message)
            .persist(to: contex.database)
            .trigger()
            .observe(on: UIScheduler())
            .on(completed: { [contex] in
                // sent message to server on side effect
                contex.network
                    .request(API.Chat.sentMessage(message))
                    .map(APIResponse<Message>.self)
                    .map(\.data)
                    .flatMapError { _ in AsyncTaskResult(value: message) }// skip error beacuse we have no backend
                    .persist(to: contex.database)
                    .start()
            })
    }
}
