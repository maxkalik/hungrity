//
//  VenueService.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/18/21.
//

import Foundation
import Combine

enum ServiceError: Error {
    case url(URLError)
    case urlRequest
    case decode
    case server
}

protocol VenuesService {
    typealias Coordinates = [Query : String]
    func getVenues(by coordinates: Coordinates) -> AnyPublisher<[Venue], Error>
}

final class VenuesServiceImplementation: VenuesService {
    func getVenues(by coordinates: Coordinates) -> AnyPublisher<[Venue], Error> {
//        var dataTask: URLSessionDataTask?
//
//        let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
//        let onCancel: () -> Void = { dataTask?.cancel() }
        
        guard let urlRequest = getUrlRequest(with: coordinates) else {
            return Fail(error: ServiceError.urlRequest).eraseToAnyPublisher()
        }
        
        print(urlRequest)
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                print("*****", response)
                let value = try JSONDecoder().decode(Venues.self, from: data)
                return value.results ?? []
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

//        return Future<[Venue], Error> { [weak self] promise in
//            guard let urlRequest = self?.getUrlRequest(with: coordinates) else {
//                promise(.failure(ServiceError.urlRequest))
//                return
//            }
//
//            dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
//                print(urlRequest)
//                guard let data = data else {
//                    if let error = error { promise(.failure(error)) }
//                    return
//                }
//                do {
//                    let venues = try JSONDecoder().decode(Venues.self, from: data)
//                    switch venues.status {
//                    case .failed: promise(.failure(ServiceError.server))
//                    case .success: promise(.success(venues.results ?? []))
//                    }
//                } catch {
//                    promise(.failure(ServiceError.decode))
//                }
//            }
//        }
//        .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
    }
    
    private func getUrlRequest(with queries: Coordinates) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "restaurant-api.wolt.fi"
        components.path = "/v3/venues"
        components.queryItems = queries.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }

        guard let url = components.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 10.0
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}
