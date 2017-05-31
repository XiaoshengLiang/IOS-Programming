//
//  CalcModel.swift
//  Calculator_MVC
//
//  Created by LiangXiaosheng on 2017/2/16.
//  Copyright © 2017 LiangXiaosheng. All rights reserved.
//

//   Control+I  reform the code


import Foundation

class CalcModel{
    
    //    private var accumulator: Double = 0.0
    private var accumulator = 0.0
    
    func setOperand(operand: Double){
        accumulator = operand
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "±" : Operation.UnaryOperation({ -$0}),
        "*" : Operation.BinaryOperation({ $0 * $1 }),
        "/" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    private struct PendingBinaryOperationInfo{
        var binaryFunction: ((Double, Double) -> Double)
        var firstOperand: Double
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    
    func performOperation(symbol: String){
        if let operation = operations[symbol]{
            switch operation{
            case .Constant(let associatedValue): accumulator = associatedValue
            case .UnaryOperation(let associatedFunction): accumulator = associatedFunction(accumulator)
            case .BinaryOperation(let function): pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals: excutePendingOperation()
            }
        }
    }
    
    private func excutePendingOperation(){
        if pending != nil{
            accumulator = (pending!.binaryFunction((pending!.firstOperand), accumulator))
            pending = nil
        }
    }
    
    var result: Double {
        get{
            return accumulator
        }
    }
}
