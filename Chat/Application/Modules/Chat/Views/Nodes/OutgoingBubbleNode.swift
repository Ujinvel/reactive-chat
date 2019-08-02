//
//  OutgoingBubbleNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class OutgoingBubbleNode: BubbleNode, ChatItem {
    enum C {
        static let margins = UIEdgeInsets(top: 0, left: CGFloat.infinity, bottom: 0, right: 10)
        static let insets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 5)
    }
    
    let margins: UIEdgeInsets = C.margins
    
    var isSelected: Bool {
        get {
            return false
        }
        set {
        }
    }
    
    init(_ contentNode: ASDisplayNode) {
        super.init(contentNode, insets: C.insets)

        style.minHeight = BubbleNode.C.contentMinHeight
        style.maxWidth = ASDimensionMakeWithFraction(0.75)
        imageNode.image = R.image.chat_bubble_outgoing()
    }
}

