import Foundation

// MARK: - Interface Segregation Principle — AFTER
//
// Split the fat protocol into small, focused ones. Each apiService conforms
// ONLY to the capabilities it genuinely supports — no empty stubs. Clients
// depend only on the narrow contract they actually need.

// MARK: - Models

struct CommentModel {
    let id: Int
    let body: String
}

struct UserModel {
    let id: Int
    let name: String
}

// MARK: - Protocols

protocol CommentReading {
    func fetchComments() -> [CommentModel]
}

protocol UserReading {
    func fetchUsers() -> [UserModel]
}

protocol CommentWriting {
    func save(_ comment: CommentModel)
}

// MARK: - ApiServices

final class RemoteCommentApiService: CommentReading, UserReading, CommentWriting {
    func fetchComments() -> [CommentModel] { [CommentModel(id: 1, body: "Server comment")] }
    func fetchUsers() -> [UserModel] { [UserModel(id: 1, name: "Alice")] }
    func save(_ comment: CommentModel) { print("💾 Saved comment #\(comment.id) to the server") }
}

final class CachedCommentApiService: CommentReading {
    func fetchComments() -> [CommentModel] { [CommentModel(id: 2, body: "Cached comment")] }
}

// MARK: - Clients

func showComments(from reader: CommentReading) {
    reader.fetchComments().forEach { print("• \($0.body)") }
}

func publish(_ comment: CommentModel, to writer: CommentWriting) {
    writer.save(comment)
}

// MARK: - Demo

showComments(from: RemoteCommentApiService())
showComments(from: CachedCommentApiService())   // CachedCommentApiService is enough — no forced stubs

publish(CommentModel(id: 3, body: "New comment"), to: RemoteCommentApiService())
