import Foundation

// MARK: - Liskov Substitution Principle — AFTER
//
// Program against an honest abstraction every conformer can fully satisfy.
// The contract: fetchComments(page:) returns that page's comments, or [] when
// none exist — no lying, no silent fallback. Remote and cached apiServices
// are both safely substitutable wherever CommentProviding is expected.

// MARK: - Models

struct CommentModel {
    let id: Int
    let body: String
}

// MARK: - Protocol

protocol CommentProviding {
    func fetchComments(page: Int) -> [CommentModel]
}

// MARK: - ApiServices

final class RemoteCommentApiService: CommentProviding {
    func fetchComments(page: Int) -> [CommentModel] {
        [CommentModel(id: page, body: "Comment from page \(page)")]
    }
}

final class CachedCommentApiService: CommentProviding {
    private let pages = [1: [CommentModel(id: 1, body: "Cached page 1")]]

    func fetchComments(page: Int) -> [CommentModel] {
        pages[page] ?? []   // honest: empty when not cached, never a wrong page
    }
}

// MARK: - Demo

func printPageTwo(using apiService: CommentProviding) {
    let comments = apiService.fetchComments(page: 2)
    if comments.isEmpty {
        print("Page 2 → (none available)")
    } else {
        comments.forEach { print("Page 2 → \($0.body)") }
    }
}

print("Remote apiService:")
printPageTwo(using: RemoteCommentApiService())   // ✅ "Comment from page 2"

print("Cached apiService:")
printPageTwo(using: CachedCommentApiService())     // ✅ "(none available)" — honest & substitutable
