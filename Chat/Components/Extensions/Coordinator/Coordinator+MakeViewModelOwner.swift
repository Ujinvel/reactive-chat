//
//  Coordinator+MakeViewModelOwner.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

extension Coordinator {
    func makeViewModelOwner<O: NSObject & ViewModelOwner & Makeable, V: UseCasesConsumer>(viewModel: V? = nil,
                                                                                          _ builder: (inout O.Product) -> Void) -> O
        where O.Product == O, O.ViewModel == V {
        guard let useCases = useCases as? V.UseCases else {
            fatalError("V.UseCases should be subset of Coordinator.UseCasesProvider")
        }
            
        let viewModelOwner: O = O.make(builder)
        viewModelOwner.coordinator = self
        viewModelOwner.viewModel = viewModel ?? V()
        viewModelOwner.viewModel.useCases = useCases
        
        return viewModelOwner
    }
}

