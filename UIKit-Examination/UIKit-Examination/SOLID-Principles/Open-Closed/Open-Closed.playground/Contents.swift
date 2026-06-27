import Foundation

// MARK: - Open/Closed Principle — AFTER
//
// Each model gets its own parser type. CommentApiService stays CLOSED — its
// source never changes — while new models are added by creating new parser
// conformers (OPEN for extension).
//
// PostModel is brand new below, yet CommentApiService needs zero edits to support it.

// MARK: - Models

struct CommentModel: Codable {
    let id: Int
    let body: String
}

struct UserModel: Codable {
    let id: Int
    let name: String
}

struct PostModel: Codable {
    let id: Int
    let title: String
}

// MARK: - Response Parser

protocol ResponseParser {
    associatedtype Model
    func parse(from json: String) -> Model
}

struct CommentResponseParser: ResponseParser {
    typealias Model = [CommentModel]

    func parse(from json: String) -> [CommentModel] {
        (try? JSONDecoder().decode([CommentModel].self, from: Data(json.utf8))) ?? []
    }
}

struct UserResponseParser: ResponseParser {
    typealias Model = [UserModel]

    func parse(from json: String) -> [UserModel] {
        (try? JSONDecoder().decode([UserModel].self, from: Data(json.utf8))) ?? []
    }
}

struct PostResponseParser: ResponseParser {
    typealias Model = [PostModel]

    func parse(from json: String) -> [PostModel] {
        (try? JSONDecoder().decode([PostModel].self, from: Data(json.utf8))) ?? []
    }
}

// MARK: - ApiService

final class CommentApiService { }

// MARK: - Public API Methods

extension CommentApiService {
    func fetch<P: ResponseParser>(_ parser: P, from json: String) -> P.Model {
        parser.parse(from: json)
    }
}

// MARK: - Demo

let apiService = CommentApiService()

let comments = apiService.fetch(CommentResponseParser(), from: #"[{"id":1,"body":"Hi"}]"#)
let users = apiService.fetch(UserResponseParser(), from: #"[{"id":1,"name":"Alice"}]"#)
let posts = apiService.fetch(PostResponseParser(), from: #"[{"id":1,"title":"Hello"}]"#)

print("Comments: \(comments.count), Users: \(users.count), Posts: \(posts.count)")
