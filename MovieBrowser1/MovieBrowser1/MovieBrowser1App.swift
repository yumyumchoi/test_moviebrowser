//
//  MovieBrowser1App.swift
//  MovieBrowser1
//
//  Created by Choi, David on 6/12/23.
//

import SwiftUI

@main
struct MovieBrowser1App: App {
    let persistenceController = PersistenceController.shared
    let movieSearchModel = MovieSearchModel()
    var body: some Scene {
        WindowGroup {
            MovieSearchView(model: movieSearchModel)
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
