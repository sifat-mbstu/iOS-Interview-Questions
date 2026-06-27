import Foundation
import Combine

final class Resource: Sendable {
    let name: String
    
    init(name: String) {
        self.name = name
        print("Resource '\(name)' created")
    }
    
    deinit {
        print("❌ Resource '\(name)' deallocated")
    }
    
    func use() {
        print("🎯 Using resource '\(name)'")
    }
}

func createResource() -> Resource {
    return Resource(name: "TemporaryResource")
}

func exampleWithExtendedLifetime() {
    // Create a temporary resource
    let resource = createResource()
    
    // Extend the lifetime of the resource
    withExtendedLifetime(resource) {
        DispatchQueue.global().async { [weak resource] in
            print("Starting work with the resource")
            resource?.use()
            print("Finishing work with the resource")
        }
    }
    
    print("Block completed")
}

exampleWithExtendedLifetime()
