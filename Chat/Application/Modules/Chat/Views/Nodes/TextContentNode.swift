//
//  TextContentNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

enum NodeMessageType {
    case outgoing, incoming
}

final class TextContentNode: ASDisplayNode {
    private enum C {
        static let savedMessagesInsets = UIEdgeInsets(top: 8, left: 14, bottom: 0, right: 8)
        static let chatIncomingInsets = UIEdgeInsets(top: 8, left: 14, bottom: 0, right: 8)
        static let chatOutgoingInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
    
    private let verticalInsets: UIEdgeInsets
    private let hozizontalInsets: UIEdgeInsets
    private let backgroundHorizontalNode: ASDisplayNode = ASDisplayNode()
    
    let textNode: ASTextNode
    let statusNode: StatusNode
    
    init(text: String,
         color: UIColor,
         statusNode: StatusNode,
         messageType: NodeMessageType) {
        self.textNode = ASTextNode()
        self.statusNode = statusNode
        // insets
        if case .outgoing = messageType {
            verticalInsets = C.chatOutgoingInsets
        } else {
            verticalInsets = C.chatIncomingInsets
        }
        hozizontalInsets = verticalInsets
        super.init()
        // font
        let font = UIFont.systemFont(ofSize: 15)
        textNode.attributedText =
            NSAttributedString(string: text,
                               attributes: [.foregroundColor: color,
                                            .font: font])
        // subnodes
        addSubnode(textNode)
        addSubnode(statusNode)
        addSubnode(backgroundHorizontalNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let horizontalSpec = makeHorizontalSpec(constrainedSize)
        let layout = horizontalSpec.layoutThatFits(constrainedSize)

        if layout.size.height <= BubbleNode.C.contentMinHeight.value + 8 {
            return horizontalSpec
        } else {
            return makeVerticalSpec(constrainedSize)
        }
    }
    
    func makeTextSpec(insets: UIEdgeInsets = .zero) -> ASLayoutElement {
        let textSpec = ASInsetLayoutSpec(insets: insets,
                                         child: ASCenterLayoutSpec(horizontalPosition: .end,
                                                                   verticalPosition: .center,
                                                                   sizingOption: .minimumSize,
                                                                   child: textNode))
        textSpec.style.flexShrink = 1
        return textSpec
    }
    
    func makeHorizontalSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textSpec = makeTextSpec(insets: .bottom(8))
        let spacing: CGFloat = 2
        let alignItems: ASStackLayoutAlignItems = .start
        return ASInsetLayoutSpec(insets: hozizontalInsets,
                                 child: ASStackLayoutSpec(direction: .horizontal,
                                                          spacing: spacing,
                                                          justifyContent: .spaceBetween,
                                                          alignItems: alignItems,
                                                          children: [textSpec, statusNode]))
    }
    
    func makeVerticalSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        statusNode.style.maxWidth = ASDimensionMake(constrainedSize.max.width)
        let itemsAlign: ASStackLayoutAlignItems = .end
        statusNode.style.minHeight = ASDimensionMake(18)
        statusNode.style.maxHeight = ASDimensionMake(18)
        statusNode.subnodesInsets = .bottom(6)
        let statusNodeSpec = ASStackLayoutSpec(direction: .horizontal,
                                               spacing: 0,
                                               justifyContent: .end,
                                               alignItems: .end,
                                               children: [statusNode])
        return ASInsetLayoutSpec(insets: verticalInsets,
                                 child: ASStackLayoutSpec(direction: .vertical,
                                                          spacing: 0,
                                                          justifyContent: .end,
                                                          alignItems: itemsAlign,
                                                          children: [makeTextSpec(), statusNodeSpec]))
    }
}

