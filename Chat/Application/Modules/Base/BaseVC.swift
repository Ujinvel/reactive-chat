//
//  BaseVC.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class BaseVC: UIViewController {
    // MARK: - Controls
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
                                     activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)])
        return activityIndicator
    }()
    
    // MARK: - Properties
    private(set)lazy var isActive: Property<Bool> = Property(initial: false, then: reactive.isActive)
    private let activityIndicator = Signal<Bool, Never>.pipe()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeActivityStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeKeyboardChange()
    }
    
    // MARK: - Observe activitie state
    private func observeActivityStates() {
        activityIndicator.output
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .observeValues { [activityIndicatorView, view] in
                if $0 {
                    activityIndicatorView.startAnimating()
                    view?.bringSubviewToFront(activityIndicatorView)
                } else {
                    activityIndicatorView.stopAnimating()
                }
        }
    }
    
    // MARK: - Keyboard change
    private func observeKeyboardChange() {
        KeyboardService.shared.keyboardContex.producer.skipNil()
            .withLatest(from: isActive)
            .take(until: reactive.viewDidDisappear.trigger())
            .startWithValues { [weak self] context, isActive in
                if isActive {
                    context.animate {
                        self?.keyboardDidChange(context)
                    }
                } else {
                    UIView.performWithoutAnimation {
                        self?.view.layoutIfNeeded()
                        self?.keyboardDidChange(context)
                    }
                }
        }
    }
    
    func keyboardDidChange(_ context: KeyboardChangeContext) {
    }
    
    // MARK: - Errors
    func errors(ignoreError: DomainError? = .noConnection) -> BindingTarget<DomainError> {
        return reactive.makeBindingTarget { `self`, error in
            if error == ignoreError {
                return
            }
            self.present(UIAlertController(DomainErrorAlert(error: error)), animated: true)
        }
    }
    
    func activity() -> BindingTarget<Bool> {
        return reactive.makeBindingTarget { $0.activityIndicator.input.send(value: $1) }
    }
}

