//
//  MovieList.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/15/22.
//

import Foundation

struct MovieList {
    var movie_type: String
    var movies: [[String : Any]]
    
    init() {
        movie_type = ""
        movies = [[String : Any]]()
    }
}
