import UIKit

/**
 Closures are self contained blocks
*/

let square: (Int) -> (Int) = { number in
    return number * number
}

// Usage
let result = square(4)
print(result)  // Output: 16

func applyTransformation(_ transformation: @escaping (Int) -> Int, to numbers: [Int]) -> [Int] {
    return numbers.map { transformation($0) }
}

let numbers = [1, 2, 3, 4, 5]

// Define a closure that doubles the input
let double: (Int) -> (Int) = { number in
    return number * 2
}

// Use the closure with the applyTransformation function
let doubledNumbers = applyTransformation(double, to: numbers)

print(doubledNumbers)  // Output: [2, 4, 6, 8, 10]
