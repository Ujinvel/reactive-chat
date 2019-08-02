//
//  FlexibleTextView.swift
//  Application
//
//  Created by Evgenyi Velichko on 6/26/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import UIKit
import ReactiveSwift

final class FlexibleTextView: UITextView {    
    public var placeholder: String? {
        get {
            return loadedPlaceholderTextView?.text
        }
        set {
            placeholderTextView.text = newValue
            setNeedsLayout()
        }
    }
    public private(set) lazy var placeholderTextView : UITextView = self.createPlaceholderTextView()
    public var maximumHeight: CGFloat = 120
    
    private let _textSize = MutableProperty<CGSize>(.zero)
    public private(set) lazy var textSize = Property(capturing: _textSize)
    public private(set) var minimumHeight: CGFloat = 0.0 {
        didSet {
            if minimumHeight > maximumHeight {
                maximumHeight = minimumHeight
            }
        }
    }
    private var needsUpdateHeight = true
    private var loadedPlaceholderTextView: UITextView?
    
    // MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if needsUpdateHeight {
            calculateMinimumHeight()
            updateTextSize()
            needsUpdateHeight = false
        }
        updateContentOffset()
    }
    
    // MARK: - Setup
    func createPlaceholderTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = .lightGray
        textView.font = font
        textView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        textView.textContainerInset = textContainerInset
        textView.frame = bounds
        addSubview(textView)
        loadedPlaceholderTextView = textView
        return textView
    }
    
    func updatePlaceholderState() {
        loadedPlaceholderTextView?.isHidden = !text.isEmpty
    }
    
    func calculateMinimumHeight() {
        minimumHeight = calculateSize(for: placeholderTextView.attributedText).height
    }
    
    @objc func textDidChange(_ notification: Notification) {
        textDidChange()
    }
    
    func textDidChange() {
        updatePlaceholderState()
        needsUpdateHeight = true
        setNeedsLayout()
    }
    
    // MARK: - Overrides
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override var font: UIFont? {
        didSet {
            loadedPlaceholderTextView?.font = font
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            loadedPlaceholderTextView?.textContainerInset = textContainerInset
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return _textSize.value
    }
    
    func calculateSize(for string: NSAttributedString) -> CGSize {
        let horizontalInsets = textContainerInset.left + textContainerInset.right
        let verticalInsets = textContainerInset.top + textContainerInset.bottom
        let size = CGSize(width: frame.width - horizontalInsets,
                          height: UILayoutFittingExpandedSize.height)
        
        let boundingRect = string.boundingRect(with: size,
                                               options: [.usesLineFragmentOrigin,
                                                         .usesFontLeading],
                                               context: nil).integral
        var newSize = boundingRect.size
        newSize.width += horizontalInsets
        newSize.height += verticalInsets
        return newSize
    }
    
    private func updateContentOffset() {
        let maxOffContentOffset = CGPoint(x: contentOffset.x, y: contentSize.height - _textSize.value.height)
        if _textSize.value.height == maximumHeight {
            if contentOffset.y > maxOffContentOffset.y {
                contentOffset = maxOffContentOffset
            }
        } else {
            contentOffset = maxOffContentOffset
        }
    }
    
    func updateTextSize() {
        var newSize = calculateSize(for: attributedText)
        
        if newSize.height < minimumHeight {
            newSize.height = minimumHeight
        }
        
        if newSize.height >= maximumHeight {
            newSize.height = maximumHeight
        }
        _textSize.value = newSize
        
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
}
