//
//  ViewController.swift
//  IosArchitectureDemo1
//
//  Created by Max Boulat on 3/26/18.
//  Copyright © 2018 Dexcom. All rights reserved.
//

class Sandbox {
    static var state1: State1!
    static var state2: State2!
    static var service: Service!
}

import UIKit

 
class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    var stateMachine: StateMachineProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
       counterLabel.text = ""

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CountUpdated"), object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            let count = notification.userInfo!["count"] as! Int
            self?.counterLabel.text = "\(count)"
        }

        // do the injection
        Sandbox.service = Service()
        Sandbox.state1 = State1(service: Sandbox.service)
        Sandbox.state2 = State2(service: Sandbox.service)
        stateMachine = StateMachine(state1: Sandbox.state1,
                                    state2: Sandbox.state2)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func didPressStart(_ sender: Any) {
        
        if stateMachine.isIncrementing == nil {
            startButton.setTitle("Stop", for: .normal)
            stateMachine.start()
        }
        else {
            startButton.setTitle("Start", for: .normal)
            stateMachine.close()
        }
    } 
    
    @IBAction func didPressCrank(_ sender: Any) {
        stateMachine.crank()
    }
    
    @IBAction func didPressClearState1(_ sender: Any) {
        Sandbox.state1 = nil
    }
    
    @IBAction func didPressClearState2(_ sender: Any) {
        Sandbox.state2 = nil
    }
    
    @IBAction func didPressClearService(_ sender: Any) {
        Sandbox.service = nil
    }
    
    @IBAction func didPressClearStateMachine(_ sender: Any) {
        stateMachine = nil
    }
}

class StateMachine: StateMachineProtocol {
    
    var state1: StateProtocol
    var state2: StateProtocol
    
    var isIncrementing: Bool?
    
    required init(state1: StateProtocol,
                  state2: StateProtocol) {
        self.state1 = state1
        self.state2 = state2
    }
    
    func start() {
        
        isIncrementing = true
        state1.start()
    }
    
    func crank() {
        
        if isIncrementing == true {
            state1.stop()
            state2.start()
            isIncrementing = false
        }
        else {
            state2.stop()
            state1.start()
            isIncrementing = true
        }
    }
    
    func close() {
        
        // cleanup
        state1.stop()
        state2.stop()
        isIncrementing = nil
    }
}

class State1: StateProtocol {
    
    var service: ServiceProtocol
    
    required init(service: ServiceProtocol) {
        self.service = service
    }
    
    func start() {
        service.increment()
    }
    
    func stop() {
        service.suspend()
    }
}

class State2: StateProtocol {
    
    var service: ServiceProtocol
    
    required init(service: ServiceProtocol) {
        self.service = service
    }
    
    func start() {
        service.decrement()
    }
    
    func stop() {
        service.suspend()
    }
}

class Service: ServiceProtocol {
    
    private var timer: Timer?
    private var counter: Int = 100
    
    func increment() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            self?.counter += 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CountUpdated"), object: nil, userInfo: ["count" : self?.counter ?? -1])
        }
    }
    
    func decrement() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            self?.counter -= 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CountUpdated"), object: nil, userInfo: ["count" : self?.counter ?? -1])
        }
    }
    
    func suspend() {
        timer?.invalidate()
    }
}



