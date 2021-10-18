//
//  Agent.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation
import Combine

struct Response<T> {
    let value: T
    let response: URLResponse
}

class NetworkService {
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> Response<T> in
                let value = try JSONDecoder().decode(T.self, from: data)
                return Response(value: value, response: response)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
