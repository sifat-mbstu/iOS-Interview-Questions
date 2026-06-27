import Foundation

// MARK: - Dependency Inversion Principle — AFTER
//
// Introduce a CommentDataProviding abstraction. CommentViewModel (high-level)
// and CommentNetworkClient / MockCommentNetworkClient (low-level) both depend
// on it. The concrete client is injected at init — swap network, mock, or cache
// without touching CommentViewModel, and tests become trivial.

// MARK: - Models

struct CommentModel: Codable {
    let id: Int
    let body: String
}

// MARK: - Protocol

protocol CommentDataProviding {
    func loadJSON() -> String
}

// MARK: - Network Clients

final class CommentNetworkClient: CommentDataProviding {
    func loadJSON() -> String { #"[{"id":1,"body":"From the network"}]"# }
}

final class MockCommentNetworkClient: CommentDataProviding {
    func loadJSON() -> String { #"[{"id":2,"body":"From a mock"}]"# }
}

// MARK: - ViewModel

final class CommentViewModel {

    // MARK: - Properties

    private let dataProvider: CommentDataProviding   // ✅ depends on abstraction

    // MARK: - Initialization

    init(dataProvider: CommentDataProviding) {
        self.dataProvider = dataProvider
    }
}

// MARK: - Public API Methods

extension CommentViewModel {
    func fetchComments() -> [CommentModel] {
        let json = dataProvider.loadJSON()
        return (try? JSONDecoder().decode([CommentModel].self, from: Data(json.utf8))) ?? []
    }
}

// MARK: - Demo

print("Network → \(CommentViewModel(dataProvider: CommentNetworkClient()).fetchComments().map(\.body))")
print("Mock    → \(CommentViewModel(dataProvider: MockCommentNetworkClient()).fetchComments().map(\.body))")
