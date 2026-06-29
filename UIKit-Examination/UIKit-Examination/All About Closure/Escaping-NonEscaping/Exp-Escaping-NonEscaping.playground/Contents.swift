import UIKit

class TestNonEscaping {
    //TODO: What Happened if return value in closure
    //TODO: Why Optional closure is always escaping
    func performAdd() {
        add(num1: 4, num2: 5) { result in
            print(result)
            chilling() //MARK: Don't Need self
        }
    }
    
    private func chilling() {
        print("Chilling! We've done it without delay.")
    }
    
    private func add<T: Numeric>(num1: T, num2: T, completion: (T) -> Void) {
        let sum = num1 + num2
        completion(sum)
    }
}

let testNonEscaping = TestNonEscaping()
testNonEscaping.performAdd()


class TestEscaping {
    func performAdd() {
        print("step1")
        
        getSumFromServer(num1: 4, num2: 9) { [weak self] result in
            print(result)
            print("step4")
            self?.chilling() //MARK: Need self
        }
        print("step2")
    }
    private func chilling() {
        print("Chill! We get sum from server")
    }
    private func getSumFromServer<T: Numeric>(num1: T, num2: T, completion: @escaping (T) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self else { return }
            let sum = num1 + num2
            print("step3")
            completion(sum)
        }
    }
}

let testEscaping = TestEscaping()
testEscaping.performAdd()
