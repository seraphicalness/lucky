import Foundation

// MARK: - API Error

enum APIError: LocalizedError {
    case httpError(Int, String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .httpError(401, _): return "로그인이 만료됐어요. 다시 로그인해 주세요."
        case .httpError(403, _): return "접근 권한이 없습니다."
        case .httpError(404, _): return "데이터를 찾을 수 없습니다."
        case .httpError(400, let msg): return "요청 오류: \(msg)"
        case .httpError(let code, _): return "서버 오류 (\(code))"
        case .decodingError: return "데이터 파싱 오류"
        case .networkError: return "네트워크 연결을 확인해 주세요."
        }
    }
}

// MARK: - APIClient

final class APIClient {
    static let shared = APIClient()

    /// 로컬 개발: http://localhost:8080
    /// 배포 후: 실제 서버 주소로 변경
    let baseURL = URL(string: "http://localhost:8080")!

    // MARK: - Decodable Response

    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        token: String? = nil,
        body: Encodable? = nil,
        responseType: T.Type,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let req = try buildRequest(path: path, method: method, token: token, body: body, queryItems: queryItems)
        let (data, response) = try await execute(req)
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError(URLError(.badServerResponse)) }
        try checkStatus(http, data: data)
        do {
            return try makeDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Void Response

    func requestVoid(
        path: String,
        method: String = "POST",
        token: String? = nil,
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        let req = try buildRequest(path: path, method: method, token: token, body: body, queryItems: queryItems)
        let (data, response) = try await execute(req)
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError(URLError(.badServerResponse)) }
        try checkStatus(http, data: data)
    }

    // MARK: - Private Helpers

    private func buildRequest(
        path: String,
        method: String,
        token: String?,
        body: Encodable?,
        queryItems: [URLQueryItem]?
    ) throws -> URLRequest {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        var components = URLComponents(url: baseURL.appendingPathComponent(cleanPath), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        var req = URLRequest(url: components.url!)
        req.httpMethod = method
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body { req.httpBody = try JSONEncoder().encode(body) }
        return req
    }

    private func execute(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func checkStatus(_ response: HTTPURLResponse, data: Data) throws {
        guard 200..<300 ~= response.statusCode else {
            let msg = String(data: data, encoding: .utf8) ?? ""
            print("❌ API [\(response.statusCode)] \(response.url?.path ?? ""): \(msg)")
            throw APIError.httpError(response.statusCode, msg)
        }
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        // 서버에서 LocalDate("yyyy-MM-dd") 또는 ISO8601이 올 수 있음
        let iso = ISO8601DateFormatter()
        let localDate = DateFormatter()
        localDate.locale = Locale(identifier: "en_US_POSIX")
        localDate.timeZone = TimeZone(secondsFromGMT: 0)
        localDate.dateFormat = "yyyy-MM-dd"

        decoder.dateDecodingStrategy = .custom { d in
            let container = try d.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = localDate.date(from: str) { return date }
            if let date = iso.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(str)")
        }

        return decoder
    }
}
