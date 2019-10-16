//
//  ChatVM.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import AsyncDisplayKit

final class ChatVM: NSObject, ViewModelDefault, UseCasesConsumer {
    typealias UseCases = HasChatUseCase
    
    // MARK: - Properties
    private lazy var dataSource = Property(value: useCases.chat.makeMessagesDataSource())
    private let dataSourceUpdates = MutableProperty<AnyChatDataSource<Message>.Updates>((insertations: (sections: .init(), items: []),
                                                                                              deletations: (sections: .init(), items: []),
                                                                                              modifications: []))
    private let dataSourceDidLoad = MutableProperty<Void>(())
    private let dataSourceDidBecomeEmpty = MutableProperty<Void>(())
    private let dataSourceExecutionTrigger = MutableProperty<Bool>(false)
    
    private let cellFactory: ChatCellFactoryProtocol = ChatCellFactory()
    private let messageToSent = MutableProperty<Message?>(nil)
    
    // MARK: - Actions
    private lazy var sentMessageAction: Action<Void, Void, DomainError> = Action(unwrapping: messageToSent, execute: useCases.chat.sent)
    
    // MARK: - Bind view for input
    func bindInput(collectionNode: ASCollectionNode,
                   chatInputView: ChatInputView,
                   placeholderLabel: UILabel) {
        bind(chatInputView)
        bind(collectionNode)
        bind(placeholderLabel)
    }
    
    private func bind(_ chatInputView: ChatInputView) {
        chatInputView.sendButton.reactive.pressed = CocoaAction(sentMessageAction)
        messageToSent <~ chatInputView.textView.reactive
          .continuousTextValues
          .producer
          .skipEmpty()
          .combineLatest(with: chatInputView.sourceSegmentControlState.producer)
          .map { body, controlSate -> Message in
            Message(localId: NSUUID().uuidString,
                    createdAt: Date(),
                    updatedAt: Date(),
                    sentAt: Date(),
                    isIncoming: controlSate == .incoming,
                    body: body)
        
        }
        chatInputView.textView.reactive.text <~ sentMessageAction.values.map { _ in "" }
        messageToSent <~ sentMessageAction.values.map { _ in nil }
    }
    
    private func bind(_ placeholderLabel: UILabel) {
        placeholderLabel.reactive.isHidden <~ SignalProducer.merge(dataSourceDidLoad,
                                                                   dataSourceDidBecomeEmpty,
                                                                   dataSourceUpdates.producer.trigger())
            .map { [dataSource] _ in !dataSource.value.isEmpty }
    }
    
    private func bind(_ collectionNode: ASCollectionNode) {
        dataSourceUpdates <~ dataSource.producer.didReceiveUpdates()
        dataSourceDidLoad <~ dataSource.producer.didLoad()
        dataSourceDidBecomeEmpty <~ dataSource.producer.didBecomeEmpty()
        dataSourceExecutionTrigger <~ dataSource.producer.executionTrigger()
        reactive.makeBindingTarget { `self`, _ in
            collectionNode.reloadData {
                if collectionNode.alpha != 1 {
                    UIView.animate(withDuration: ChatVC.C.ChatAnimation.appearanceDuration, animations: {
                        collectionNode.alpha = 1
                    })
                }
                self.dataSource.value.didProcessedUpdates()
            }
        } <~ SignalProducer.merge(dataSourceDidLoad, dataSourceDidBecomeEmpty)
        reactive.makeBindingTarget { `self`, input in
            let (updates, dataSource) = input
            collectionNode.performBatch(animated: true, updates: {
                collectionNode.insertSections(updates.insertations.sections)
                collectionNode.insertItems(at: updates.insertations.items)
                collectionNode.deleteSections(updates.deletations.sections)
                collectionNode.deleteItems(at: updates.deletations.items)
                collectionNode.reloadItems(at: updates.modifications.filter {
                    $0.item < dataSource.numberOfItemsInSectionAt($0.section)
                })
            }) { _ in
                dataSource.didProcessedUpdates()
            }
            } <~ dataSourceUpdates.producer
                .withLatest(from: dataSource)
        dataSource.value.resume()
    }
    
    func nextPage() {
        dataSource.value.nextPage()
    }
    
    // MARK: - Bind view for output
    func bindOutput(errors: BindingTarget<DomainError>,
                    activity: BindingTarget<Bool>) {
        activity <~ dataSourceExecutionTrigger.producer.skip(first: 1)
        errors <~ sentMessageAction.errors
    }
    
    // MARK: - ASCollectionDataSource
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return dataSource.value.sectionsCount
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return dataSource.value.numberOfItemsInSectionAt(section)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellBlock: ASCellNodeBlock = { [dataSource, cellFactory] in
            if let itemMessage = dataSource.value.item(at: indexPath) {
                return cellFactory.makeCell(for: itemMessage)
            }
            return cellFactory.makeEmptyCell()
        }
        return cellBlock
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> ASCellNodeBlock {
        var dateString = "N/A"
        if let date = dataSource.value.dateHeader(at: indexPath.section) {
            dateString = DateFormatter.groupedByDate(yearEnabled: !date.compare(.isSameYear(Date()))).string(from: date)
        }
        return { [cellFactory] in cellFactory.makeSectionHeader(title: dateString, inverted: false) }
    }
}
