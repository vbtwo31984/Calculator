//
//  ViewController.swift
//  Calculator
//
//  Created by Vladimir Burmistrovich on 5/2/16.
//  Copyright © 2016 Vladimir Burmistrovich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var historyDisplay: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            if newValue != nil {
                display.text = String(newValue)
            }
            else {
                display.text = ""
            }
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if digit == "." {
                if display.text!.rangeOfString(".") != nil {
                    return
                }
            }
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if displayValue != nil {
                brain.setOperand(displayValue!)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            displayValue = brain.result
        }
        
        var description = brain.description
        if(brain.isPartialResult) {
            description += " …"
        }
        else {
            description += " ="
        }
        historyDisplay.text = description
    }
    
    @IBAction private func clear() {
        display.text = "0"
        historyDisplay.text = " "
        brain = CalculatorBrain()
    }
    
    @IBAction private func backspace() {
        if userIsInTheMiddleOfTyping {
            display.text!.removeAtIndex(display.text!.endIndex.predecessor());
            if display.text! == "" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        }
    }
}

