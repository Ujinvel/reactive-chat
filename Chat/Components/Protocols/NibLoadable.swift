//
//  NibLoadable.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

protocol NibLoadable: class {
}

extension NibLoadable where Self: UIView {
    static func instantiateFromNib() -> Self {
        let nibName = "\(Self.self)"
        return UINib(nibName: nibName, bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as! Self // swiftlint:disable:this force_cast
    }
}

extension UIView: NibLoadable {
}
