//
//  NetworkGatewayTests.swift
//  MovieBrowser1Tests
//
//  Created by Choi, David on 6/14/23.
//

import XCTest
import Combine

final class NetworkGatewayTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.cancellables = []
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    @MainActor
    func testMovieSearchAPI() throws {
        let expectation1 = self.expectation(description: "gateway received data")
        struct TestMovieNetworkRequestType: MovieNetworkRequestType {
            var searchQuery: String
            var queryParams: String? {
                return "query=\(searchQuery)"
            }
            var endpointPath = "search/movie"
        }
        
        let urlSession = URLSession(configuration: .default)
        let searchMovieRequestResource = TestMovieNetworkRequestType(searchQuery: "Bat")
        let networkGateway = NetworkGateway(urlSession:urlSession)
        var movieDataList: Array<MovieSimpleType> = []
        var testError: Error?
        
        // really shouldnt be testing live api, but will eventually switch to mock service
        networkGateway.load(searchMovieRequestResource, RawMovieSimpleType.self)
            .map({ searchedResult in
                XCTAssertTrue(searchedResult.results.count > 0)
                return searchedResult.results
            })
            .removeDuplicates()
            .sink(receiveCompletion: { (completion) in
                if case let .failure(error) = completion {
                    switch error {
                    default:
                        print("error \(error)")
                        testError = error
                        XCTFail("Failed on network response")
                    }
                    
                }
            }, receiveValue: { rawMovieDataCollection in
                print("received value from gateway")
                for rawMovieData in rawMovieDataCollection {
                    let movieData = MovieSimpleType(title: rawMovieData.title, id: rawMovieData.id)

                    movieDataList.append(movieData)
                }
                expectation1.fulfill()
            })
            .store(in: &cancellables)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let newMovie1 = MovieSimpleType(title: "Snow white", id: 1111)
//            movieDataList.append(newMovie1)
//            expectation1.fulfill()
//        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(testError)
        XCTAssertTrue(movieDataList.count > 0)
    }

}
