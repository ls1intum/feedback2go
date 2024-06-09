//
//  RESTController.swift
//  Themis
//
//  Created by Tom Rudnick on 11.11.22.
//

import Foundation
import UserStore

class RESTController {
    static var shared = RESTController(baseURL: (UserSessionFactory.shared.institution?.baseURL ?? URL(string: "https://artemis.ase.cit.tum.de/")!))

    var baseURL: URL

    private var jsonEncoder = JSONEncoder()
    private var jsonDecoder = JSONDecoder()

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func sendRequest(_ request: Request) async throws {
        let request = try makeURLRequest(request)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    func sendRequest<T: Decodable>(_ request: Request) async throws -> T {
        try await sendRequest(request, decode: { data in
            jsonDecoder.dateDecodingStrategy = .customISO8601
            return try jsonDecoder.decode(T.self, from: data)
        })
    }

    func sendRequest<T>(_ request: Request, decode: (Data) throws -> T) async throws -> T {
        let request = try makeURLRequest(request)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        // check for empty response
        if data.isEmpty {
            throw RESTError.empty
        }

        return try decode(data)
    }

    private func validate(response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 400:
            throw RESTError.badRequest
        case 401:
            throw RESTError.unauthorized
        case 403:
            guard let jsonDict = json as? [String: Any], let detail = jsonDict["detail"] as? String else { throw RESTError.forbidden }
            throw CustomError.error(title: RESTError.forbidden.errorDescription ?? "Forbidden", description: detail)
        case 404:
            throw RESTError.notFound
        case 405:
            throw RESTError.methodNotAllowed
        case 500..<600:
            guard let jsonDict = json as? [String: Any], let detail = jsonDict["message"] as? String else { throw RESTError.server }
            throw CustomError.error(title: RESTError.server.errorDescription ?? "Server error", description: detail)
        default:
            throw RESTError.different
        }
    }

    private func makeURLRequest(_ request: Request) throws -> URLRequest {
        let url = makeURL(with: request.path, params: request.params)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        if let body = request.body {
            let encodedBody = try jsonEncoder.encode(body)
            urlRequest.httpBody = encodedBody
        }
        return urlRequest
    }

    private func makeURL(with path: String, params: [URLQueryItem]) -> URL {
        var newURL = baseURL
        newURL.append(path: path)
        newURL.append(queryItems: params)
        return newURL
    }
}
