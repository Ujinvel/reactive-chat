//
//  ChatInputView.swift
//  Application
//
//  Created by Cleveroad on 11/2/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class ChatInputView: UIView {
    enum SegmentControlState: Int, CaseIterable {
        case outgoing, incoming
        
        init(rawValue: Int) {
            if let segment = ChatInputView.SegmentControlState.allCases[safe: rawValue] {
                self = segment
            } else {
                fatalError("Invalid rawValue")
            }
        }
    }
    
    private enum C {
        static let maxStatusMessageSymbolsCount = 10000
        
        enum Shadow {
            static let opacity: Float = 0.06
            static let radius: CGFloat = 11
            static let offset: CGSize = CGSize(width: 0, height: -3)
            static let color: CGColor = UIColor.black.cgColor
        }
        enum TextView {
            static let backgroundColor: UIColor = .white
            static let textContainerInset = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 10)
            static let placeholder = "Type something"
            static let textColor: UIColor = .lightGray
            static let cornerRadius: CGFloat = 6
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private(set) var sourceSegmentControl: UISegmentedControl!
    @IBOutlet private(set) var activeView: UIView!
    @IBOutlet private(set) var textView: FlexibleTextView!
    @IBOutlet private(set) var sendButton: UIButton!
    
    // MARK: - Properties
    private var userInputRange: NSRange?
    private var sourceSegmentState: SegmentControlState = .outgoing
    
    lazy var sourceSegmentControlState: Property<ChatInputView.SegmentControlState> = Property(initial: .outgoing,
                                                                                               then: reactive
                                                                                                .signal(for: #selector(ChatInputView.sourceSegmentControlValueChanged(_:)))
                                                                                                .map { [weak self] _ in self?.sourceSegmentState }
                                                                                                .skipNil())
    
    // MARK: - Init
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    open func commonInit() {
        textView.delegate = self
        layer.shadowOffset = C.Shadow.offset
        layer.shadowColor = C.Shadow.color
        layer.shadowOpacity = C.Shadow.opacity
        layer.shadowRadius = C.Shadow.radius
        translatesAutoresizingMaskIntoConstraints = false
        
        setupTextView()
    }
    
    // MARK: - Setup
    func setupTextView() {
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = C.TextView.backgroundColor
        textView.returnKeyType = .default
        textView.enablesReturnKeyAutomatically = true
        textView.textContainerInset = C.TextView.textContainerInset
        textView.placeholder = C.TextView.placeholder
        textView.placeholderTextView.textColor = C.TextView.textColor
        textView.layer.cornerRadius = C.TextView.cornerRadius
    }
    
    // MARK: - Overrides
    open override var intrinsicContentSize: CGSize {
        return textView.textSize.value
    }
    
    // MARK: - Actions
    @IBAction func sourceSegmentControlValueChanged(_ sender: UISegmentedControl) {
        sourceSegmentState = SegmentControlState(rawValue: sender.selectedSegmentIndex)
    }
}

    // MARK: - UITextViewDelegate
extension ChatInputView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
        
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.components(separatedBy: " ").count > 1 {
            userInputRange = nil
        } else {
            userInputRange = NSRange(location: range.location + text.utf16.count, length: range.length)
        }
        if let resultText = textView.text.cropText(replacementText: text, range: range, maxSymbolsCount: C.maxStatusMessageSymbolsCount) {
            textView.text = resultText
            
            return false
        }
        return true
    }
}
