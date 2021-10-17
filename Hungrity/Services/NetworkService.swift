//
//  NetworkService.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation
import Combine

enum Query: String {
    case latitude = "lat"
    case longitude = "lon"
}

typealias Queries = [Query : String]

enum NetworkService {
    static let agent = Agent()
    
    
    
    enum HTTPMethod: String {
        case get = "GET"
    }
    
    
    
    enum FailureReason: Error {
        case sessionFailed(error: URLError)
        case decodingFailed
        case invalidEndpoint
        case other(Error)
    }
    
    static func fetchData<Output: Decodable>(from request: URLRequest?) -> AnyPublisher<Output, FailureReason> {
        
        guard let request = request else {
            return Fail(error: FailureReason.invalidEndpoint).eraseToAnyPublisher()
        }
        
        return agent
            .run(request)
            .map(\.value)
            .mapError({ error in
                switch error {
                case is Swift.DecodingError:
                    print("=== decoding failed")
                    return .decodingFailed
                case let urlError as URLError:
                    print("=== url error: \(urlError.localizedDescription)")
                    return .sessionFailed(error: urlError)
                default:
                    print("=== other error: \(error.localizedDescription)")
                    return .other(error)
                }
            })
            .eraseToAnyPublisher()
    }
}

extension NetworkService {
    
    static let helper = NetworkServiceHelper()

    static func fetchVenues(with queries: Queries? = nil) -> AnyPublisher<Venues, FailureReason> {
        let baseUrl = URL(string: Constants.baseUrl)
        var request: URLRequest?
        
        if let queries = queries {
            let urlWithQueries = helper.prepareQueries(queries, in: baseUrl)
            request = helper.prepareRequest(from: urlWithQueries, httpMethod: .get)
        } else {
            request = helper.prepareRequest(from: baseUrl, httpMethod: .get)
        }
        
        return fetchData(from: request)
    }
}

final class NetworkServiceHelper {
    
    func prepareQueries(_ queries: Queries, in url: URL?) -> URL? {
        guard let url = url else { return nil }
        
        let queryItems = queries.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }
    
    func prepareRequest(from url: URL?, httpMethod: NetworkService.HTTPMethod) -> URLRequest? {
        guard let url = url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        return request
    }
}
