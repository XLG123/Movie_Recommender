//
//  TrendingMovies.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/15/22.
//

import Foundation

struct TrendingMovies: Decodable {
    var page: Int
    var results = [Movie]()
    var total_pages: Int
    var total_results: Int
}
