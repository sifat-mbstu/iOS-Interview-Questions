import UIKit

// MARK: - First Question

var value = 0

@MainActor func letsUnderstandDefer() -> Int {
    defer {
        value = value + 1
    }
    
    return value
}
letsUnderstandDefer()
print(value)

/*
 Output:

 0
 1
 
 */

// MARK: - Second Question


func question2() {
    print("step0")
    defer {
       print("step1")
    }
    
    defer {
       print("step2")
    }
    
    defer {
       print("step3")
    }
    
    print("step4")
}

question2()

/*
output:
 
 step0
 step4
 step3
 step2
 step1
 
 */

// MARK: - Third Question


func question3() {
    print("step0")
    defer {
       print("step1")
    }
    
    defer {
        defer {
           print("step5")
        }
       print("step2")
    }
    
    defer {
       print("step3")
    }
    
    print("step4")
}

question3()

/*
output:
 
 step0
 step4
 step3
 step2
 step5
 step1
 
 */
