import Foundation

// MARK: - Dependency Inversion Principle — BEFORE
//
// "High-level modules should not depend on low-level modules. Both should
//  depend on abstractions."
//
// CommentViewModel (high-level) creates and depends DIRECTLY on the concrete
// CommentNetworkClient (low-level). We cannot swap in a mock, cache, or file
// without editing CommentViewModel, and unit tests must hit the real client.

// MARK: - Models

struct CommentModel: Codable {
    let id: Int
    let body: String
}

// MARK: - Network Client

final class CommentNetworkClient {
    func loadJSON() -> String {
        #"[{"id":1,"body":"From the network"}]"#
    }
}

// MARK: - ViewModel

final class CommentViewModel {

    private let networkClient = CommentNetworkClient()   // ❌ hard-wired concretion

    func fetchComments() -> [CommentModel] {
        let json = networkClient.loadJSON()
        return (try? JSONDecoder().decode([CommentModel].self, from: Data(json.utf8))) ?? []
    }
}

// MARK: - Demo

let viewModel = CommentViewModel()
let comments = viewModel.fetchComments()
print("Loaded \(comments.count) comment(s): \(comments.map(\.body))")
