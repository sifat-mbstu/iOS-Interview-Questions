import Foundation

// MARK: - Single Responsibility Principle — BEFORE
//
// "A type should have only ONE reason to change."
//
// CommentApiService below has THREE reasons to change:
//   1. Transport  — how raw data is obtained
//   2. Parsing    — how that data is decoded into models
//   3. Reporting  — how results/errors are logged
//
// A change to any one of these forces us to edit — and re-test — this
// same class. Responsibilities are tangled together.

// MARK: - Models

struct CommentModel: Codable {
    let id: Int
    let name: String
    let body: String
}

// MARK: - ApiService

final class CommentApiService {

    func fetchComments(from json: String) -> [CommentModel] {
        // Responsibility 1: obtain raw data
        let data = Data(json.utf8)

        // Responsibility 2: decode the data
        guard let comments = try? JSONDecoder().decode([CommentModel].self, from: data) else {
            // Responsibility 3: logging
            print("❌ Decoding failed")
            return []
        }

        print("✅ Fetched and decoded \(comments.count) comments")
        return comments
    }
}

// MARK: - Demo

let sampleJSON = """
[
  { "id": 1, "name": "Alice", "body": "First comment" },
  { "id": 2, "name": "Bob",   "body": "Second comment" }
]
"""

let apiService = CommentApiService()
let comments = apiService.fetchComments(from: sampleJSON)
comments.forEach { print("• \($0.name): \($0.body)") }
