//
//  QueuedOperation.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//
//
import Foundation
import Combine

open class QueuedOperation: Operation {
    private var _executing = false
    open override var isExecuting : Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _finished = false
    open override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    open var disposable: AnyCancellable?
    
    public init(priority: Operation.QueuePriority = .veryLow) {
        super.init()
        
        self.queuePriority = priority
        self.qualityOfService = .background
    }
    
    open override func start() {
        guard !isCancelled else {
            completed()
            return
        }
        
        isExecuting = true
        main()
    }
    
    open override func main() {
        guard !isCancelled else {
            completed()
            return
        }
        
        completed()
    }
    
    open override func cancel() {
        disposable?.cancel()
        dependencies.forEach { $0.cancel() }
        
        super.cancel()
        isFinished = true
    }
    
    open func completed() {
        isExecuting = false
        isFinished = true
        disposable?.cancel()
    }
}
