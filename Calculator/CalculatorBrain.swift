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
    private var accumulatorAsString: String {
        get {
            let formatter = NSNumberFormatter()
            formatter.maximumFractionDigits = 6
            return formatter.stringFromNumber(accumulator)!
        }
    }
    
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
        "÷": Operation.BinaryOperation({$0 / $1}),
        "Rand": Operation.NullaryOperation(drand48)
    ]
    
    private enum Operation {
        case Constant(Double)
        case NullaryOperation(() -> Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    private var pending: PendingBinaryOperationInfo?
    private var pendingConstant = false
    private var lastOperation = "";
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperant: Double
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                if isPartialResult && lastOperation != symbol {
                    description += " \(symbol)"
                }
                else if !isPartialResult {
                    description = symbol
                }
                pendingConstant = true
            case .UnaryOperation(let function):
                if symbol == "x²" {
                    if isPartialResult || description == "" {
                        description += " \(accumulatorAsString)²"
                    }
                    else {
                        description = "(\(description))²"
                    }
                }
                else {
                    if isPartialResult || description == "" {
                        description += " \(symbol)(\(accumulatorAsString))"
                    }
                    else {
                        description = "\(symbol)(\(description))"
                    }
                }
                pendingConstant = true
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                if isPartialResult {
                    executePendingBinaryOperation()
                    description += " \(symbol)"
                }
                else {
                    description = "\(accumulatorAsString) \(symbol)"
                }
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperant: accumulator)
            case .NullaryOperation(let function):
                accumulator = function()
                if isPartialResult {
                    description += " \(accumulatorAsString)"
                }
                else {
                    description = String(accumulatorAsString)
                }
            case .Equals:
                executePendingBinaryOperation()
            }
            lastOperation = symbol
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            if !pendingConstant {
                description += " \(accumulatorAsString)"
                pendingConstant = false
            }
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