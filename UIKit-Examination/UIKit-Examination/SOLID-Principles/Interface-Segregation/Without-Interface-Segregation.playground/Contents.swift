import Foundation

// MARK: - Interface Segregation Principle — BEFORE
//
// "No client should be forced to depend on methods it does not use."
//
// One fat CommentDataSource bundles reading comments, reading users, and
// writing. RemoteCommentApiService supports all three — but CachedCommentApiService
// can only read comments, yet must provide empty no-op stubs for the rest.
// Those stubs are a smell: the cache is forced to depend on methods it
// does not actually support.

// MARK: - Models

struct CommentModel {
    let id: Int
    let body: String
}

struct UserModel {
    let id: Int
    let name: String
}

// MARK: - Protocol

protocol CommentDataSource {
    func fetchComments() -> [CommentModel]
    func fetchUsers() -> [UserModel]
    func save(_ comment: CommentModel)
}

// MARK: - ApiServices

final class RemoteCommentApiService: CommentDataSource {
    func fetchComments() -> [CommentModel] { [CommentModel(id: 1, body: "Server comment")] }
    func fetchUsers() -> [UserModel] { [UserModel(id: 1, name: "Alice")] }
    func save(_ comment: CommentModel) { print("💾 Saved comment #\(comment.id) to the server") }
}

final class CachedCommentApiService: CommentDataSource {
    func fetchComments() -> [CommentModel] { [CommentModel(id: 2, body: "Cached comment")] }

    func fetchUsers() -> [UserModel] { [] }           // 🤷 the cache has no users
    func save(_ comment: CommentModel) { }            // 🤷 the cache is read-only
}

// MARK: - Demo

let apiServices: [CommentDataSource] = [RemoteCommentApiService(), CachedCommentApiService()]
apiServices.forEach { apiService in
    apiService.fetchComments().forEach { print("• \($0.body)") }
}
