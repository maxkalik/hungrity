//
//  NetworkService.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation
import Combine

enum ServiceError: Error {
    case sessionFailed(error: URLError)
    case decodingFailed
    case invalidEndpoint
    case other(Error)
    case server
}

enum Query: String {
    case latitude = "lat"
    case longitude = "lon"
}

protocol VenuesServiceProtocol {
    typealias Coordinates = [Query : String]
    func fetchVenues(by coordinates: Coordinates) -> AnyPublisher<[Venue], ServiceError>
}

final class VenuesService: VenuesServiceProtocol {
    let networkService = NetworkService()

    func fetchData<Output: Decodable>(from request: URLRequest?) -> AnyPublisher<Output, ServiceError> {
        
        guard let request = request else {
            return Fail(error: ServiceError.invalidEndpoint).eraseToAnyPublisher()
        }
        
        return networkService
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

extension VenuesService {
    func fetchVenues(by coordinates: Coordinates) -> AnyPublisher<[Venue], ServiceError> {
        let request = prepareRequest(with: coordinates)
        let venuesPublisher: AnyPublisher<Venues, ServiceError> = fetchData(from: request)
        return venuesPublisher
            .tryMap { try self.transformVenues($0) }
            .map { $0.results ?? [] }
            .mapError { $0 as? ServiceError ?? ServiceError.other($0) }
            .eraseToAnyPublisher()
    }

    private func transformVenues(_ venues: Venues) throws -> Venues {
        switch venues.status {
        case .failed: throw ServiceError.server
        case .success: return venues
        }
    }

    private func prepareRequest(with queries: Coordinates) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Constants.basehost
        components.path = Constants.basepath
        components.queryItems = queries.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }

        guard let url = components.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 10.0
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}
