//
//  ChatCellFactory.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class ChatCellFactory: ChatCellFactoryProtocol {
    func makeCell(for message: Message) -> ASCellNode {
        let messageType: NodeMessageType = message.isIncoming ? .incoming : .outgoing
        let statusNode = StatusNode(dateString: message.sentAt.displayMessage,
                                    messageType: messageType)
        let contentNode = TextContentNode(text: message.body,
                                          color: message.textColor,
                                          statusNode: statusNode,
                                          messageType: messageType)
        let itemNode: ChatCellNode.ItemNode = message.isIncoming ? IncomingBubbleNode(contentNode) : OutgoingBubbleNode(contentNode)
        let node = ChatCellNode(itemNode)
        node.neverShowPlaceholders = true
        
        return node
    }
    
    func makeSectionHeader(title: String, inverted: Bool) -> ASCellNode {
        let sectionNode = ChatCellNode(DateSectionNode(dateString: title, inverted: inverted))
        sectionNode.isUserInteractionEnabled = false
        return sectionNode
    }
    
    func makeEmptyCell() -> ASCellNode {
        return ASCellNode()
    }
}

