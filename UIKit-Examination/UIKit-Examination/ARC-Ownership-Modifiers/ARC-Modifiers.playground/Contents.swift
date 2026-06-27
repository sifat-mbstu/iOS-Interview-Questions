// ============================================================
// MARK: - At a Glance: Interview 10-15 Seconds
// ============================================================
//
// strong:
// - Owns the object.
// - Keeps it alive.
// - Increases reference count.
// - Risk: retain cycle.
//
// weak:
// - Does not own the object.
// - Does not keep it alive.
// - Automatically becomes nil.
// - Usually optional.
// - Best for delegates, parent references, [weak self].
//
// unowned:
// - Does not own the object.
// - Does not keep it alive.
// - Does not become nil.
// - Usually non-optional.
// - Can crash if accessed after deallocation.
// - Use only when lifetime is 100% guaranteed.
//
// One-line answer:
//
// strong keeps object alive.
// weak does not keep object alive and becomes nil.
// unowned does not keep object alive, does not become nil,
// and may crash if the object is already gone.
//
// Interview shortcut:
//
// Use strong for ownership.
// Use weak to break retain cycles safely.
// Use unowned only when the referenced object must live longer.

import Foundation

// ============================================================
// MARK: - Swift Ownership Modifiers: strong vs weak vs unowned
// ============================================================
//
// ARC = Automatic Reference Counting.
//
// ARC keeps a class instance alive as long as at least one
// strong reference points to it.
//
// Interview summary:
//
// strong
// - Owns the object.
// - Increases reference count.
// - Keeps object alive.
// - Can create retain cycle if two objects strongly reference each other.
//
// weak
// - Does not own the object.
// - Does not increase reference count.
// - Automatically becomes nil when the object is deallocated.
// - Must usually be optional.
// - Safer than unowned.
//
// unowned
// - Does not own the object.
// - Does not increase reference count.
// - Does not become nil.
// - Can crash if accessed after the object is deallocated.
// - Use only when lifetime is guaranteed.


// ============================================================
// MARK: - 1. Strong Reference Example
// ============================================================

final class Engine {
    init() {
        print("Engine init")
    }

    deinit {
        print("Engine deinit")
    }
}

final class Car {
    let engine: Engine

    init(engine: Engine) {
        self.engine = engine
        print("Car init")
    }

    deinit {
        print("Car deinit")
    }
}

func strongReferenceExample() {
    print("\n--- 1. Strong Reference Example ---")

    var car: Car? = Car(engine: Engine())

    // Memory:
    //
    // car ──strong──▶ Car ──strong──▶ Engine
    //
    // car strongly owns Car.
    // Car strongly owns Engine.

    print("Setting car = nil")
    car = nil

    // Expected output:
    //
    // Car deinit
    // Engine deinit
}


// ============================================================
// MARK: - 2. Strong Reference Cycle Problem
// ============================================================

final class StrongPerson {
    var apartment: StrongApartment?

    deinit {
        print("StrongPerson deinit")
    }
}

final class StrongApartment {
    var tenant: StrongPerson?

    deinit {
        print("StrongApartment deinit")
    }
}

func strongCycleExample() {
    print("\n--- 2. Strong Cycle Example ---")

    var person: StrongPerson? = StrongPerson()
    var apartment: StrongApartment? = StrongApartment()

    person?.apartment = apartment
    apartment?.tenant = person

    // Memory:
    //
    // person ──strong──▶ StrongPerson ──strong──▶ StrongApartment
    //                         ▲                         │
    //                         │                         │
    //                         └────────strong───────────┘
    //
    // StrongPerson owns StrongApartment.
    // StrongApartment owns StrongPerson.
    //
    // This creates a retain cycle.

    print("Setting external references to nil")

    person = nil
    apartment = nil

    // Expected by beginner:
    //
    // StrongPerson deinit
    // StrongApartment deinit
    //
    // Actual:
    //
    // No deinit print.
    //
    // Why?
    //
    // Because StrongPerson and StrongApartment still strongly
    // hold each other.
}


// ============================================================
// MARK: - 3. Weak Reference Fix
// ============================================================

final class WeakPerson {
    var apartment: WeakApartment?

    deinit {
        print("WeakPerson deinit")
    }
}

final class WeakApartment {
    weak var tenant: WeakPerson?

    deinit {
        print("WeakApartment deinit")
    }
}

func weakReferenceExample() {
    print("\n--- 3. Weak Reference Example ---")

    var person: WeakPerson? = WeakPerson()
    var apartment: WeakApartment? = WeakApartment()

    person?.apartment = apartment
    apartment?.tenant = person

    // Memory:
    //
    // person ──strong──▶ WeakPerson ──strong──▶ WeakApartment
    //                       ▲                       │
    //                       │                       │
    //                       └────────weak───────────┘
    //
    // WeakApartment does not own WeakPerson.
    // So there is no retain cycle.

    print("Setting external references to nil")

    person = nil
    apartment = nil

    // Expected output:
    //
    // WeakPerson deinit
    // WeakApartment deinit
}


// ============================================================
// MARK: - 4. Unowned Reference Example
// ============================================================

final class Customer {
    let name: String
    var creditCard: CreditCard?

    init(name: String) {
        self.name = name
        print("Customer init")
    }

    func assignCreditCard(number: String) {
        self.creditCard = CreditCard(number: number, customer: self)
    }

    deinit {
        print("Customer deinit")
    }
}

final class CreditCard {
    let number: String

    // CreditCard does not own Customer.
    // But CreditCard assumes Customer will exist while CreditCard is used.
    //
    // unowned means:
    //
    // 1. Do not increase reference count.
    // 2. Do not become nil.
    // 3. Crash if accessed after Customer is deallocated.

    unowned let customer: Customer

    init(number: String, customer: Customer) {
        self.number = number
        self.customer = customer
        print("CreditCard init")
    }

    func printOwner() {
        print("Card \(number) belongs to \(customer.name)")
    }

    deinit {
        print("CreditCard deinit")
    }
}

func unownedReferenceExample() {
    print("\n--- 4. Unowned Reference Example ---")

    var customer: Customer? = Customer(name: "Sifat")
    customer?.assignCreditCard(number: "1234-5678")

    customer?.creditCard?.printOwner()

    // Memory:
    //
    // Customer ──strong──▶ CreditCard
    //    ▲                    │
    //    │                    │
    //    └────unowned─────────┘
    //
    // Customer owns CreditCard.
    // CreditCard does not own Customer.
    //
    // This avoids retain cycle.
    // Also customer is non-optional inside CreditCard.

    print("Setting customer = nil")
    customer = nil

    // Expected output:
    //
    // Customer deinit
    // CreditCard deinit
    //
    // No crash here because CreditCard is also deallocated
    // when Customer is deallocated.
}


// ============================================================
// MARK: - 5. Unowned Crash Risk Example
// ============================================================
//
// This example is intentionally not called at the bottom.
//
// It shows the dangerous case:
// CreditCard is still alive, but Customer is already gone.

func unownedCrashRiskExample_DoNotRunAccessLine() {
    print("\n--- 5. Unowned Crash Risk Example ---")

    var customer: Customer? = Customer(name: "Sifat")
    customer?.assignCreditCard(number: "9999-0000")

    var card: CreditCard? = customer?.creditCard

    // Memory:
    //
    // customer ──strong──▶ Customer ──strong──▶ CreditCard
    // card ─────────────────────────strong────▶ CreditCard
    //
    // CreditCard ──unowned──▶ Customer

    print("Setting customer = nil")
    customer = nil

    // Customer is now deallocated.
    // But CreditCard is still alive because variable card strongly holds it.
    //
    // The unowned customer reference inside CreditCard is now dangling.
    //
    // If you uncomment the next line, the app can crash:
    //
    // card?.printOwner()

    card = nil

    // Now CreditCard deallocates.
}


// ============================================================
// MARK: - 6. Weak Version of Same Relationship
// ============================================================

final class WeakCustomer {
    let name: String
    var creditCard: WeakCreditCard?

    init(name: String) {
        self.name = name
        print("WeakCustomer init")
    }

    func assignCreditCard(number: String) {
        self.creditCard = WeakCreditCard(number: number, customer: self)
    }

    deinit {
        print("WeakCustomer deinit")
    }
}

final class WeakCreditCard {
    let number: String
    weak var customer: WeakCustomer?

    init(number: String, customer: WeakCustomer) {
        self.number = number
        self.customer = customer
        print("WeakCreditCard init")
    }

    func printOwner() {
        if let customer {
            print("Card \(number) belongs to \(customer.name)")
        } else {
            print("Customer is nil. No crash.")
        }
    }

    deinit {
        print("WeakCreditCard deinit")
    }
}

func weakVsUnownedSafetyExample() {
    print("\n--- 6. Weak Safety Example ---")

    var customer: WeakCustomer? = WeakCustomer(name: "Sifat")
    customer?.assignCreditCard(number: "5555-1111")

    var card: WeakCreditCard? = customer?.creditCard

    print("Setting customer = nil")
    customer = nil

    // Weak reference automatically becomes nil.
    // So this will not crash.

    card?.printOwner()

    card = nil
}


// ============================================================
// MARK: - 7. Interview Notes
// ============================================================
//
// Question:
// What is the difference between strong, weak, and unowned?
//
// Answer:
// strong keeps an object alive.
// weak does not keep an object alive and becomes nil automatically.
// unowned does not keep an object alive and does not become nil.
// Accessing unowned after the object is deallocated can crash.
//
// ------------------------------------------------------------
//
// Question:
// Why is weak usually optional?
//
// Answer:
// Because when the referenced object is deallocated, Swift automatically
// sets the weak reference to nil.
//
// Example:
//
// weak var customer: Customer?
//
// ------------------------------------------------------------
//
// Question:
// Why can unowned be non-optional?
//
// Answer:
// Because unowned references are not automatically set to nil.
// Swift assumes the referenced object will always exist when accessed.
//
// Example:
//
// unowned let customer: Customer
//
// ------------------------------------------------------------
//
// Question:
// What is the problem if we use weak instead of unowned?
//
// Answer:
// There is usually no serious problem. weak is safer.
// But weak has tradeoffs:
//
// 1. It must usually be optional.
// 2. You need optional handling.
// 3. It allows nil state.
// 4. It may hide lifetime bugs.
//
// Example:
//
// weak var invoice: Invoice?
//
// This means InvoiceItem may exist without Invoice.
// If that is logically wrong, unowned let can express the model better.
//
// ------------------------------------------------------------
//
// Question:
// When should we use unowned?
//
// Answer:
// Use unowned only when all are true:
//
// 1. The reference must never be nil.
// 2. The referenced object is guaranteed to live longer.
// 3. The current object should not own the referenced object.
// 4. You want non-optional access.
// 5. You are 100% sure about lifetime.
//
// ------------------------------------------------------------
//
// Practical iOS rule:
//
// delegate                      -> weak
// parent reference              -> weak
// coordinator back reference    -> weak
// viewModel property            -> strong
// service property              -> strong
// API closure self capture      -> [weak self]
// Timer closure self capture    -> [weak self]
// guaranteed lifetime reference -> unowned


// ============================================================
// MARK: - Run Examples
// ============================================================

strongReferenceExample()
strongCycleExample()
weakReferenceExample()
unownedReferenceExample()
weakVsUnownedSafetyExample()

// Do not call this unless you want to test crash behavior manually.
// unownedCrashRiskExample_DoNotRunAccessLine()
