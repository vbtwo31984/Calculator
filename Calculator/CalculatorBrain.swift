//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vladimir Burmistrovich on 5/2/16.
//  Copyright © 2016 Vladimir Burmistrovich. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private var accumulator = 0.0
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
        "±": Operation.UnaryOperation({-$0}),
        "x²": Operation.UnaryOperation({$0 * $0}),
        "=": Operation.Equals,
        "+": Operation.BinaryOperation({$0 + $1}),
        "−": Operation.BinaryOperation({$0 - $1}),
        "×": Operation.BinaryOperation({$0 * $1}),
        "÷": Operation.BinaryOperation({$0 / $1})
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        description = description + String(operand) + " "
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperant: Double
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperant: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
            if symbol != "=" {
                description = description + symbol + " "
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperant, accumulator)
            pending = nil
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var description = ""
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
}