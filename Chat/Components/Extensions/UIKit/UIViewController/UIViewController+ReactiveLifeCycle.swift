//
//  UIViewController+ReactiveLifeCycle.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result
import Foundation

public extension Reactive where Base: UIViewController {
    var viewDidLoad: Signal<Void, NoError> {
        return trigger(for: #selector(Base.viewDidLoad))
    }
    
    var viewWillAppear: Signal<Bool, NoError> {
        return signal(for: #selector(Base.viewWillAppear(_:)))
            .map { $0.first as! Bool }
    }
    
    var viewDidAppear: Signal<Bool, NoError> {
        return signal(for: #selector(Base.viewDidAppear(_:)))
            .map { $0.first as! Bool }
    }
    
    var viewWillDisappear: Signal<Bool, NoError> {
        return signal(for: #selector(Base.viewWillDisappear(_:)))
            .map { $0.first as! Bool }
    }
    
    var viewDidDisappear: Signal<Bool, NoError> {
        return signal(for: #selector(Base.viewDidDisappear(_:)))
            .map { $0.first as! Bool }
    }
    
    var viewWillLayoutSubviews: Signal<Void, NoError> {
        return trigger(for: #selector(Base.viewWillLayoutSubviews))
    }
    
    var viewDidLayoutSubviews: Signal<Void, NoError> {
        return trigger(for: #selector(Base.viewDidLayoutSubviews))
    }
    
    var didReceiveMemoryWarning: Signal<Void, NoError> {
        return trigger(for: #selector(Base.didReceiveMemoryWarning))
    }
    
    var applicationDidBecomeActive: Signal<Void, NoError> {
      return NotificationCenter.default.reactive.notifications(forName: UIApplication.didBecomeActiveNotification).map { _ in }
    }
    
    var isActive: Signal<Bool, NoError> {
        return Signal.merge(viewDidAppear.map { _ in true },
                            viewWillDisappear.map { _ in false })
    }
    
    var isVisible: Signal<Bool, NoError> {
        return Signal.merge(applicationDidBecomeActive.map { _ in true },
                            viewWillAppear.map { _ in true },
                            viewDidDisappear.map { _ in false })
    }
}

