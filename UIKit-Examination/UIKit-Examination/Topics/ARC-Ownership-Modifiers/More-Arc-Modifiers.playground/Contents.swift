import Foundation
import PlaygroundSupport

// MARK: - Interview Note

/*
 Interview explanation:

 withExtendedLifetime:
 Swift ARC may release an object after its last real use.
 withExtendedLifetime tells Swift to keep that object alive until
 the closure returns.

 borrowing:
 The function gets temporary access to a value without taking ownership.
 The caller keeps the value and can still use it afterward.

 consuming:
 The function receives ownership of the value.
 This is useful when the function is the final user of that value,
 or when it needs to store/forward it.

 */

// Ensure background threads run smoothly in the Playground environment
PlaygroundPage.current.needsIndefiniteExecution = true

func section(_ title: String) {
    print("\n=== SYSTEM LOG: \(title.uppercased()) ===")
}

// =============================================================================
// MARK: - 1. TEMPORARY RESOURCE LIFECYCLES
// =============================================================================

/**
 `TemporaryResource` simulates a reference-tracked system allocation.
 
 - Note: Under normal circumstances, Swift's Automatic Reference Counting (ARC)
   can deallocate an instance immediately following its last explicit synchronous use,
   ignoring any hidden or unstructured asynchronous bindings.
 */
class TemporaryResource {
    let id: String
    
    init(id: String) {
        self.id = id
        print("💾 Resource '\(id)' created.")
    }
    
    func use() {
        print("🎯 Using resource '\(id)' inside critical operation.")
    }
    
    deinit {
        print("❌ Resource '\(id)' deallocated from memory.")
    }
}

/**
 Helper function matching the article's structure to clean up setup logic.
 */
func createResource() -> TemporaryResource {
    return TemporaryResource(id: "TemporaryResource")
}


// =============================================================================
// MARK: - 2. DEMONSTRATING THE LIFETIME GUARANTEE
// =============================================================================

/**
 Replicates the core problem and solution shown in the article's async workflow.
 */
func exampleWithExtendedLifetime() {
    section("withExtendedLifetime Scenario")
    
    let resource = createResource()
    
    /*
     THE GUARANTEE:
     `withExtendedLifetime` ensures that the target instance is not cleared by ARC before
     the execution of this closure completes.
     
     THE PITFALL:
     As highlighted in the article, this function behaves synchronously. To safely access
     the instance inside an asynchronous callback (`DispatchQueue.global().async`), we must
     leverage a capture list (`[weak resource]` or `[resource]`) to safely retain or observe
     the value when the background thread catches up.
     */
    withExtendedLifetime(resource) {
        DispatchQueue.global().async { [weak resource] in
            print("🚀 [Background] Starting work with the resource...")
            resource?.use()
            print("🏁 [Background] Finishing work with the resource.")
        }
    }
    
    print("📢 Main synchronous block completed.")
}


// =============================================================================
// MARK: - 3. VALUE OWNERSHIP MODIFIERS
// =============================================================================

struct Person {
    let name: String
}

/**
 Accesses the parameter data without increasing reference counts.
 
 - Parameter person: A `borrowing` parameter. The function gains temporary read-only access.
   No ARC retain/release commands are performed on the caller's stack frame.
 */
func printPersonName(_ person: borrowing Person) {
    print("👋 Hello, \(person.name) [Borrowed Context]")
}

/**
 Transfers exclusive control over the passed object to this specific scope.
 
 - Parameter person: A `consuming` parameter. The target function accepts total ownership.
   Once invoked, the compiler marks the original token as invalid for the caller.
 */
func sayGoodbye(_ person: consuming Person) {
    print("🚪 Goodbye, \(person.name) [Consumed Context]")
    // The instance's underlying allocations end exactly when this scope exits.
}


// =============================================================================
// MARK: - 4. EXECUTING THE SYSTEM TESTS
// =============================================================================

func runOwnershipDemo() {
    section("Parameter Ownership Modifiers")
    
    let person = Person(name: "John Doe")
    
    // 1. Borrowing: Accessing multiple times is safe since ownership is kept.
    printPersonName(person)
    printPersonName(person)
    
    // 2. Consuming: Pass complete authority of the data over to the callee.
    sayGoodbye(person)
    
    // -------------------------------------------------------------------------
    // CRITICAL INTERVIEW NOTE:
    // If working with strict Noncopyable (`~Copyable`) data types, uncommenting
    // the statement below throws a strict *Compile-Time Error*.
    // Error: "'person' used after consume"
    // -------------------------------------------------------------------------
    // printPersonName(person)
}

// Execute demonstrations
exampleWithExtendedLifetime()

// Delay the ownership execution slightly so logs don't entangle with the async background task
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    runOwnershipDemo()
}

// Safely close the playground execution environment once asynchronous operations rest
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    section("All System Probes Completed Successfully")
    PlaygroundPage.current.finishExecution()
}
