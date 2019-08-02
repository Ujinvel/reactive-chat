//
//  StatusNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class StatusNode: ASDisplayNode {
    private enum C {
        static let imageSize = CGSize(width: 12, height: 12)
    }
    
    private(set) lazy var dateNode = ASTextNode()
    private(set) lazy var statusImageNode = ASImageNode()
    
    var subnodesInsets: UIEdgeInsets = .top(8)
    
    init(dateString: String,
         messageType: NodeMessageType) {
        super.init()
        var statusImage: UIImage!
        var textColor: UIColor!
        switch messageType {
        case .outgoing:
            textColor = .white
            statusImage = R.image.chat_status_pending_white()!
        case .incoming:
            textColor = .black
            statusImage = R.image.chat_status_pending_azure()!
            
        }
        let font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        let attribites: [NSAttributedStringKey: Any] = [.foregroundColor: textColor,
                                                        .font: font]
        dateNode.attributedText = NSAttributedString(string: dateString, attributes: attribites)
        statusImageNode.image = statusImage
        
        addSubnode(dateNode)
        statusImageNode.contentMode = .scaleAspectFit
        statusImageNode.image = statusImage
        addSubnode(statusImageNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insettedDateSpec = ASInsetLayoutSpec(insets: subnodesInsets, child: dateNode)
        if statusImageNode.image != nil {
            statusImageNode.style.preferredSize = C.imageSize
        }
        let statusImageNodeInsets = UIEdgeInsets(top: subnodesInsets.top, left: 4, bottom: subnodesInsets.bottom, right: 0)
        let activeNodes: [ASLayoutElement] = [insettedDateSpec, ASInsetLayoutSpec(insets: statusImageNodeInsets, child: statusImageNode)]
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0),
                                 child: ASStackLayoutSpec(direction: .horizontal,
                                                          spacing: 2,
                                                          justifyContent: .end,
                                                          alignItems: .center,
                                                          children: activeNodes))
    }
}

