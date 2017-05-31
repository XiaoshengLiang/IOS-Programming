//
//  ViewController.swift
//  Calculator_MVC
//
//  Created by LiangXiaosheng on 2017/2/16.
//  Copyright © 2017 LiangXiaosheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurrentInDisplay = display.text
            display.text = textCurrentInDisplay! + digit
        }else{
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double{
        get{
            return Double(display.text!)! 
        }
        set{
            display.text = String(newValue)
        }
    }
    
    var model = CalcModel()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping{
            model.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        let mathsymbol = sender.currentTitle!
        model.performOperation(symbol: mathsymbol)
        displayValue = model.result
        }
}

