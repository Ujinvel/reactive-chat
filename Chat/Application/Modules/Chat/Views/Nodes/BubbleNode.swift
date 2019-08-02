//
//  BubbleNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BubbleNode: ASDisplayNode {
    enum C {
        static let avatarMaxHeight = ASDimensionMake(40)
        static let userNameInsets = UIEdgeInsets(top: 0, left: 60, bottom: 4, right: 6)
        static let avatarImageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        static let userNameMaxHeight = ASDimensionMake(30)
        static let contentMinHeight = ASDimensionMake(35)
        static let statusFrameWidth: CGFloat = 44.0
        static let replySpecOutgoingInsets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 0, right: 10)
        static let replySpecIncomingInsets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 0, right: 10)
    }
    
    let imageNode: ASImageNode
    let contentNode: ASDisplayNode
    var userNameTextNode: ASTextNode?
    var avatarImageNode: ASImageNode?
    let insets: UIEdgeInsets
    
    // MARK: - Life cycle
    init(_ contentNode: ASDisplayNode,
         insets: UIEdgeInsets,
         userName: String? = nil) {
        self.contentNode = contentNode
        self.insets = insets
        self.imageNode = ASImageNode()
        super.init()
        
        setupAvatarImageNode()
        setupUserNameNode(withUserName: userName)
        addSubnode(imageNode)
        addSubnode(contentNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        contentNode.style.minHeight = C.contentMinHeight
        let content = ASInsetLayoutSpec(insets: insets, child: contentNode)
        var overlay: ASLayoutSpec
        overlay = ASOverlayLayoutSpec(child: content, overlay: imageNode)
        if let userNameTextNode = userNameTextNode, let avatarImageNode = avatarImageNode {
            overlay = ASOverlayLayoutSpec(child: content, overlay: imageNode)
            contentNode.style.maxWidth = ASDimensionMake(constrainedSize.max.width - C.avatarMaxHeight.value - 18)
            let userNameLayoutSpec = ASInsetLayoutSpec(insets: C.userNameInsets, child: userNameTextNode)
            let avatarImageLayoutSpec = ASInsetLayoutSpec(insets: C.avatarImageInsets, child: avatarImageNode)
            let avatarWithContentSpec = ASStackLayoutSpec(direction: .horizontal,
                                                          spacing: 0,
                                                          justifyContent: .start,
                                                          alignItems: .end,
                                                          children: [avatarImageLayoutSpec, overlay])
            return ASStackLayoutSpec(direction: .vertical,
                                     spacing: 0,
                                     justifyContent: .start,
                                     alignItems: .start,
                                     children: [userNameLayoutSpec, avatarWithContentSpec])
        }
        
        return overlay
    }
    
    // MARK: - Setup
    private func setupAvatarImageNode(_ image: UIImage = R.image.chat_avatar_placeholder()!) {
        let avatarImageNode = ASImageNode()
        addSubnode(avatarImageNode)
        avatarImageNode.style.maxLayoutSize = ASLayoutSize(width: C.avatarMaxHeight, height: C.avatarMaxHeight)
        avatarImageNode.image = image
        avatarImageNode.imageModificationBlock = {
            $0.rounded(withCornerRadius: C.avatarMaxHeight.value,
                       divideRadiusByImageScale: true)
        }
        
        self.avatarImageNode = avatarImageNode
    }
    
    private func setupUserNameNode(withUserName name: String?) {
        guard let name = name else { return }
        
        let userNameTextNode = ASTextNode()
        addSubnode(userNameTextNode)
        userNameTextNode.style.maxHeight = C.userNameMaxHeight
        userNameTextNode.attributedText =
            NSAttributedString(string: name,
                               attributes: [.foregroundColor: UIColor.lightGray,
                                            .font: UIFont.systemFont(ofSize: 15)])
        
        self.userNameTextNode = userNameTextNode
    }
}

