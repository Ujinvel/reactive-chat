//
//  ChatCellNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class ChatCellNode: ASCellNode {
    enum C {
        static let checkBoxDimesion = ASDimensionMake(22)
        static let checkBoxIncomingInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        static let checkBoxOutgoingInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    typealias ItemNode = ASDisplayNode & ChatItem
    
    let itemNode: ItemNode
    
    public init(_ itemNode: ItemNode) {
        self.itemNode = itemNode
        super.init()
        automaticallyManagesSubnodes = true
        addSubnode(itemNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: itemNode.margins, child: itemNode)
    }
}
