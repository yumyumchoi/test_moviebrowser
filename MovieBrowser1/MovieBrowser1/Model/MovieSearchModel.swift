//
//  MovieSearchModel.swift
//  MovieBrowser1
//
//  Created by Choi, David on 6/12/23.
//

import Foundation
import Combine

struct MovieSearchNetworkRequest: MovieNetworkRequestType {
    var searchQuery: String
    var queryParams: String? {
        return "query=\(searchQuery)"
    }
    var endpointPath = "search/movie"
}

struct MovieSimpleType: Codable, Identifiable {
    var title: String
    var id: Int
}

struct RawMovieSimpleResult: Codable, Equatable {
    var title: String
    var id: Int
}

struct RawMovieSimpleType: Codable {
    var page: Int
    var results: [RawMovieSimpleResult]
}

protocol MovieSearchModelProtocol: AnyObject, ObservableObject {
    var movieListForQuery: [MovieSimpleType] { get }
    var cancellableSet: Set<AnyCancellable> { get }
    func updateSearchQuery(_ query: String)
}

class MovieSearchModel: MovieSearchModelProtocol {
    var currentQuery: String?
    @Published private var movieSearchQuery: String = ""
    @Published var movieListForQuery: [MovieSimpleType] = []
    var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        $movieSearchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .filter({$0.count > 2})
            .removeDuplicates()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("error \(error)")
                }
            }, receiveValue: { result in
                print("search query updated = \(result)")
                self.searchForQuery(result)
            })
            .store(in: &self.cancellableSet)
    }
    
    func updateSearchQuery(_ query: String) {
        self.movieSearchQuery = query
    }
    
    private func searchForQuery(_ query: String) {
        guard query.count > 0 else { movieListForQuery = []; return; }
        
        self.movieListForQuery = []
        self.cancellableSet = []
        
        let urlSession = URLSession(configuration: .default)
        let searchMovieRequestResource = MovieSearchNetworkRequest(searchQuery: query)
        let networkGateway = NetworkGateway(urlSession:urlSession)
        
        networkGateway.load(searchMovieRequestResource, RawMovieSimpleType.self)
//            .receive(on: RunLoop.main)
            .map({ searchedResult in
                return searchedResult.results
            })
            .removeDuplicates()
            .sink(receiveCompletion: { (completion) in
                if case let .failure(error) = completion {
                    switch error {
                    default:
                        print("error \(error)")
                    }
                }
            }, receiveValue: { rawMovieDataCollection in
                for rawMovieData in rawMovieDataCollection {
                    let movieData = MovieSimpleType(title: rawMovieData.title, id: rawMovieData.id)
                    
                    self.movieListForQuery.append(movieData)
                }
            })
            .store(in: &cancellableSet)
    }
    
    private func appendMockDataToMovieList() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let newMovie1 = MovieSimpleType(title: "Snow white", id: 1111)
//            let newMovie2 = MovieSimpleType(title: "White Christmas", id: 222)
//            let newMovie3 = MovieSimpleType(title: "Christmas Story", id: 3131)
//            self.movieListForQuery.append(newMovie1)
//            self.movieListForQuery.append(newMovie2)
//            self.movieListForQuery.append(newMovie3)
//        }
    }
}
