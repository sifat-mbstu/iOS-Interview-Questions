import UIKit

var greeting = "Hello, playground"

// MARK: Are optional closures escaping or non-escaping?
// Answer: Escaping

// MARK: Why does Swift treat optional closure as escaping?
// Answer: It doesn’t make sense to add escaping annotations to optional closures because they aren’t function types: they are basically an enum (Optional) containing a function, the same way you would store a closure in any type: it’s implicitly escaping because it’s owned by another type.

// Define a function that accepts an optional closure
class TestOptinalClosure {
    func performAdd() {
        print("Optional Closure Step 1")
        add(num1: 4, num2: 5) { [weak self] result in
            print(result)
            DispatchQueue.main.async {
                self?.chilling() //MARK: Need self so it's escaping
                print("Optional Closure Step 4")
            }
        }
        print("Optional Closure Step 3")
    }
    
    private func chilling() {
        print("Optional Closure: Chilling! This is how optional closure is escaping.")
    }
    
    private func add<T: Numeric>(num1: T, num2: T, completion: ((T) -> Void)? = nil ) {
        print("Optional Closure Step 2")
        let sum = num1 + num2
        completion?(sum)
    }
}

let testOptinalClosure = TestOptinalClosure()
testOptinalClosure.performAdd()
