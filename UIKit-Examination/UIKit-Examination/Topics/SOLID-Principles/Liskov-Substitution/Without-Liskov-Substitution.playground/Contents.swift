import Foundation

// MARK: - Liskov Substitution Principle — BEFORE
//
// "Subtypes must be substitutable for their base type without breaking
//  the program."
//
// CommentApiService promises: fetchComments(page:) returns THAT page's comments.
// LatestOnlyCommentApiService ignores `page` and always returns page 1 — it
// looks like a comment service but silently breaks the contract. Code written
// against the base type now misbehaves. That violates LSP.

// MARK: - Models

struct CommentModel {
    let id: Int
    let body: String
}

// MARK: - ApiService

class CommentApiService {
    func fetchComments(page: Int) -> [CommentModel] {
        [CommentModel(id: page, body: "Comment from page \(page)")]
    }
}

final class LatestOnlyCommentApiService: CommentApiService {
    override func fetchComments(page: Int) -> [CommentModel] {
        [CommentModel(id: 1, body: "Comment from page 1")]   // wrong whenever page != 1
    }
}

// MARK: - Demo

func printPageTwo(using apiService: CommentApiService) {
    let comments = apiService.fetchComments(page: 2)
    comments.forEach { print("Asked for page 2 → \($0.body)") }
}

print("Base apiService:")
printPageTwo(using: CommentApiService())

print("Subtype (violates LSP):")
printPageTwo(using: LatestOnlyCommentApiService())   // ❌ prints page 1, not page 2
