//
//  UIEdgeInsets+Short.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

public extension UIEdgeInsets {
    static func top(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: 0, bottom: 0, right: 0)
    }
    
    static func left(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: value, bottom: 0, right: 0)
    }
    
    static func bottom(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
    }
    
    static func right(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: value)
    }
    
    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: value / 2, bottom: 0, right: value / 2)
    }
    
    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value / 2, left: 0, bottom: value / 2, right: 0)
    }
    
    static func all(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
    var horizontal: CGFloat {
        return left + right
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
    
    static func + (_ lhs: UIEdgeInsets, _ rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top + rhs.top,
                            left: lhs.left + rhs.left,
                            bottom: lhs.bottom + rhs.bottom,
                            right: lhs.right + rhs.right)
    }
}

public extension CGRect {
    func inset(_ insets: UIEdgeInsets) -> CGRect {
        return self.inset(by: insets)
    }
}

public extension CGPoint {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}

