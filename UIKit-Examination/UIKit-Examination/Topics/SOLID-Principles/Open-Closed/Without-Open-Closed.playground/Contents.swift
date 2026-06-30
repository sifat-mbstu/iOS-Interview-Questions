import Foundation

// MARK: - Open/Closed Principle — BEFORE
//
// "Software entities should be OPEN for extension but CLOSED for
//  modification."
//
// CommentApiService routes every model through one switch. Each new model
// (User, Post, …) forces us to MODIFY this class and re-test all paths.
// The class is not closed for modification.

// MARK: - Models

struct CommentModel: Codable {
    let id: Int
    let body: String
}

struct UserModel: Codable {
    let id: Int
    let name: String
}

enum ResponseModelType {
    case comment
    case user
}

// MARK: - ApiService

final class CommentApiService {

    func fetch(_ model: ResponseModelType, from json: String) -> Any {
        let data = Data(json.utf8)

        switch model {
        case .comment:
            return (try? JSONDecoder().decode([CommentModel].self, from: data)) ?? []
        case .user:
            return (try? JSONDecoder().decode([UserModel].self, from: data)) ?? []
        // Need Posts next? Add another case here — and modify this method again.
        }
    }
}

// MARK: - Demo

let apiService = CommentApiService()

let comments = apiService.fetch(.comment, from: #"[{"id":1,"body":"Hi"}]"#) as! [CommentModel]
let users = apiService.fetch(.user, from: #"[{"id":1,"name":"Alice"}]"#) as! [UserModel]

print("Comments: \(comments.count), Users: \(users.count)")
