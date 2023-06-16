//
//  MovieSearchView.swift
//  MovieBrowser1
//
//  Created by Choi, David on 6/12/23.
//

import SwiftUI
import Combine

@MainActor
struct MovieSearchView: View {
    @ObservedObject var model: MovieSearchModel
    @State private var searchQuery: String = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach (self.model.movieListForQuery) { section in
                    Text(section.title)
                }
            }
        }.searchable(text: $searchQuery)
            .onChange(of: searchQuery) { textInput in
                self.runSearch(textInput)
            }
    }
    
    func runSearch(_ query:String) {
        self.model.updateSearchQuery(query)
    }
}

struct MovieSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MovieSearchModel()
        MovieSearchView(model: model)
    }
}
