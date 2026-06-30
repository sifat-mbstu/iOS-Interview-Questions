import UIKit

/**
 Non-Escaping Closures
 A non-escaping closure will not live or remain in memory once the function that calls this closure finish execution
 
 func performTaskWithNonEscapingClosure(action: () -> Void) {
     action()
 }

 */


/**
 
 Escaping Closures
 An escaping closure will remain in memory after the function from which  they gets called finish execution.
 Generally used in api calls where code run asynchronously and execution time unknown.
 
 func performTaskWithEscapingClosure(completion: @escaping () -> Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         completion()
     }
 }
 */

/**
 Key Differences
 -------------------------------------------------
 escapingClosure {
     print("I'll execute 3 seconds after the function returns.")
 }
 nonEscapingClosure {
     print("This will be executed immediately.")
 }
 ----------------------------------------------------
 - Lifetime:
     Escaping: Can outlive the function it was passed to.
     Non-Escaping: Must be called within the function it was passed to.
 
 - Syntax:
     Escaping: Requires the @escaping keyword.
     Non-Escaping: Default behavior, no keyword needed.
 
 - Usage Context:
     Escaping: Commonly used in asynchronous operations.
     Non-Escaping: Suitable for synchronous operations.
 
 - Memory Management:
     Escaping: Potential for retain cycles, thus needs careful management using capture lists.
     Non-Escaping: Safer in terms of memory management as it does not persist beyond the function's scope.

 
 */
