//
//  IncomingBubbleNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class IncomingBubbleNode: BubbleNode, ChatItem {
    var isSelected: Bool {
        set {
        }
        get {
            return false
        }
    }
    
    enum C {
        static let margins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: CGFloat.infinity)
        static let contentInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
    }
    
    // MARK: - Properties
    let margins: UIEdgeInsets = C.margins
    
    // MARK: - Life cycle
    init(_ contentNode: ASDisplayNode,
         userName: String = "Incoming participant") {
        super.init(contentNode, insets: C.contentInsets, userName: userName)
        
        setupImageColor()
    }
    
    // MARK: - Setup
    private func setupImageColor() {
        //imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(.blue)
        imageNode.image = R.image.chat_bubble_incoming()
    }
}
