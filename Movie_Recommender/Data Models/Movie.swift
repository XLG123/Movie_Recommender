//
//  Movie.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/15/22.
//

import Foundation

struct Movie: Decodable {
    let poster_path: String
    let vote_average: Float
    let overview: String
    let release_date: String
    let backdrop_path: String
    let id: Int
    let genre_ids: [Int]
    let title: String
    let original_language: String
    let popularity: Float
}
