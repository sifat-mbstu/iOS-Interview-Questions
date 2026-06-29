import UIKit

/**
 What are trailing closures?
    Trailing closures are simply syntactic sugar in Swift that allow us to implement closures without a ton of boilerplate code. When the final parameter in a call to a function is a closure, trailing closures allow you to define the closure’s contents outside of the function call.
 */

class TestTrailingClosure {
    func add(num1: Int, num2: Int, completion: (Int) -> Void) {
        
    }
    //USING Trailing CLosure
    func doAddOperation() {
        add(num1: 4, num2: 5) { sum in
            print(sum)
        }
    }
    //Without Trailing Closure
    func doAddOperationRegular() {
        add(num1: 4, num2: 5, completion: { sum in
            print(sum)
        })
    }
}
let test = TestTrailingClosure()
test.doAddOperation()
test.doAddOperationRegular()
