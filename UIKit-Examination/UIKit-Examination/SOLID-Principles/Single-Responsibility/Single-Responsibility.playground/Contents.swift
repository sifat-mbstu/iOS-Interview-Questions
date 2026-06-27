import Foundation

// MARK: - Single Responsibility Principle — AFTER
//
// Each collaborator has exactly ONE reason to change:
//
//   CommentRequestLoader   → how raw data is obtained   (transport)
//   CommentResponseDecoder → how data becomes models    (parsing)
//   CommentFetchLogger     → how outcomes are reported  (logging)
//   CommentApiService      → wiring the three together  (coordination)
//
// A parsing change touches only CommentResponseDecoder; a logging-format
// change touches only CommentFetchLogger — each can be tested in isolation.

// MARK: - Models

struct CommentModel: Codable {
    let id: Int
    let name: String
    let body: String
}

// MARK: - Result

enum AppResult<Success> {
    case success(Success)
    case failure(Error)
}

// MARK: - Request Loader

final class CommentRequestLoader {
    func loadData(from json: String) -> Data {
        Data(json.utf8)
    }
}

// MARK: - Response Decoder

final class CommentResponseDecoder {
    func decode(from data: Data) -> AppResult<[CommentModel]> {
        do {
            let comments = try JSONDecoder().decode([CommentModel].self, from: data)
            return .success(comments)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Logger

final class CommentFetchLogger {
    func logSuccess(count: Int) {
        print("✅ Fetched and decoded \(count) comments")
    }

    func logFailure() {
        print("❌ Decoding failed")
    }
}

// MARK: - ApiService

final class CommentApiService {

    // MARK: - Properties

    private let requestLoader: CommentRequestLoader
    private let responseDecoder: CommentResponseDecoder
    private let logger: CommentFetchLogger

    // MARK: - Initialization

    init(
        requestLoader: CommentRequestLoader = CommentRequestLoader(),
        responseDecoder: CommentResponseDecoder = CommentResponseDecoder(),
        logger: CommentFetchLogger = CommentFetchLogger()
    ) {
        self.requestLoader = requestLoader
        self.responseDecoder = responseDecoder
        self.logger = logger
    }
}

// MARK: - Public API Methods

extension CommentApiService {
    func fetchComments(from json: String) -> [CommentModel] {
        let data = requestLoader.loadData(from: json)

        switch responseDecoder.decode(from: data) {
        case .success(let comments):
            logger.logSuccess(count: comments.count)
            return comments
        case .failure:
            logger.logFailure()
            return []
        }
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
