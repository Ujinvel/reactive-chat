//
//  UseCases.swift
//  Chat
//
//  Created by Ujin on 7/31/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift

protocol ChatUseCase: AutoUseCaseProvider {
    func makeMessagesDataSource() -> AnyChatDataSource<Message>
    func sent(message: Message) -> TriggerResult
}
