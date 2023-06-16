//
//  NetworkGateway.swift
//  MovieBrowser1
//
//  Created by Choi, David on 6/13/23.
//

import Foundation
import Combine

enum NetworkError: Error {
    case requestError
    case invalidRequest
    case invalidResponseError
}

protocol MovieNetworkRequestType {
//    var authorizationToken: String { get }
//    var baseURL: String { get }
    var queryParams: String? { get }
    var endpointPath: String { get }
//    var request: URLRequest? { get }
}

extension MovieNetworkRequestType {
    var authorizationToken: String {
        return "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4ZTc1ZGYzYmRlOWM2ODE1Njc0MjcxYjk1YmNkZmE5NCIsInN1YiI6IjY0ODA5ZmY1OTkyNTljMDExYzNlNWQwZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.C1zPNoM74MO93N9Vis9bvDZocsANuee4pfqLcbtAWMk"
    }
    
    var baseURL: String {
        return "https://api.themoviedb.org/3/"
    }
    
    var defaultQueryParams: String {
        return "include_adult=true&language=en-US"
    }
    //query=bat&include_adult=false&language=en-US&page=1
    
    var request: URLRequest? {
        var fullURLString = baseURL + endpointPath + "?" + defaultQueryParams
        if let queryParams = queryParams, queryParams.count > 0 {
            fullURLString += "&" + queryParams
        }
        guard let url = URL(string: fullURLString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}

protocol NetworkGatewayProtocol {
//    func load<RequestType: MovieNetworkRequestType,DataType: Decodable>(_ requestResource: RequestType, _ dataType: DataType.Type) -> AnyPublisher<DataType, Error>
}

struct NetworkGateway: NetworkGatewayProtocol {
    var urlSession: URLSession
    
    init (urlSession:URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func test<T: Numeric>(_ param1: T) {
//        if Data
        print("test \(param1 + 1)")
        return
    }
    
    func load<RequestType: MovieNetworkRequestType,DataType: Decodable>(_ requestResource: RequestType, _ dataType: DataType.Type) -> AnyPublisher<DataType, Error> {
        guard let request = requestResource.request else {
            return Fail(error: NetworkError.requestError).eraseToAnyPublisher()
        }
        return self.urlSession.dataTaskPublisher(for: request)
            .mapError { _ in
                NetworkError.invalidRequest
                
            }
            .tryMap { (data: Data, response: URLResponse) in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponseError
                }
                guard 200..<300 ~= response.statusCode else {
                    throw NetworkError.invalidResponseError
                }
                return data
            }
            .decode(type: dataType, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
