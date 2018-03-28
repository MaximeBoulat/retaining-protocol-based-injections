//
//  StateMachine.swift
//  IosArchitectureDemo1
//
//  Created by Max Boulat on 3/26/18.
//
//  Copyright (c) 2018 Dexcom, Inc.
//  Licenses to third-party material that may be incorporated into this software are listed at www.dexcom.com/notices
//

import Foundation


protocol StateMachineProtocol: class {
    
    var isIncrementing: Bool? { get }
    
    init(state1: StateProtocol,
         state2: StateProtocol)
    func start()
    func crank()
    func close()
}

protocol StateProtocol: class { 
    
    init(service: ServiceProtocol)
    func start()
    func stop()
}

protocol ServiceProtocol: class {
    
    func increment()
    func decrement()
    func suspend()
}


