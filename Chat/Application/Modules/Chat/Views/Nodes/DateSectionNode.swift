//
//  DateSectionNode.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class DateSectionNode: ASDisplayNode & ChatItem {
    private(set) lazy var dateNode = ASTextNode()
    private(set) lazy var backgroundNode = ASImageNode()
    
    let margins: UIEdgeInsets = .vertical(16)
    
    var isSelected: Bool {
        get {
            return false
        }
        set {
            if newValue {
            } else {
            }
        }
    }
    
    init(dateString: String, inverted: Bool) {
        super.init()
        
        backgroundNode.image = UIImage.draw(cornerRadius: 10, fillColor: .white)
        addSubnode(backgroundNode)
        
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let attribites: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray,
                                                        .font: font]
        dateNode.attributedText = NSAttributedString(string: dateString, attributes: attribites)
        if inverted {
            dateNode.transform = CATransform3DMakeScale(1, -1, 1)
        }
        addSubnode(dateNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = ASInsetLayoutSpec(insets: .horizontal(20) + .vertical(4),
                                       child: dateNode)
        let overlay = ASOverlayLayoutSpec(child: insets, overlay: backgroundNode)
        return ASRelativeLayoutSpec(horizontalPosition: .center,
                                    verticalPosition: .center,
                                    sizingOption: .minimumSize,
                                    child: overlay)
    }
}

