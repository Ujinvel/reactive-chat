//
//  Keyboard.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

extension KeyboardChangeContext {
    func animate(_ animation: () -> Void) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(animationCurve)
        UIView.setAnimationDuration(animationDuration)
        animation()
        UIView.commitAnimations()
    }
    
    func intersection(with view: UIView) -> CGRect {
        let viewFrame = view.convert(view.bounds, to: nil)
        return endFrame.intersection(viewFrame)
    }
    
    func inset(scrollView: UIScrollView) {
        let bottomInset = intersection(with: scrollView).height
        scrollView.contentInset.bottom = bottomInset
        scrollView.scrollIndicatorInsets.bottom = bottomInset
    }
}

final class KeyboardService {
    static let shared = KeyboardService()
    
    private let _keyboardContext: MutableProperty<KeyboardChangeContext?> = .init(nil)
    private(set) lazy var keyboardContex: Property<KeyboardChangeContext?> = Property(capturing: self._keyboardContext)
    
    private init() {
        _keyboardContext <~ NotificationCenter.default.reactive.keyboardChange
    }
}

