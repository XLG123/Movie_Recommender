//
//  MovieDetailsViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/29/22.
//

import UIKit
import AlamofireImage

class MovieDetailsViewController: UIViewController {

    
    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieSynopsis: UILabel!
    @IBOutlet weak var providersCollectionView: UICollectionView!
    
    var movieSelected: [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if movieSelected["title"] != nil {
            self.navigationItem.title = movieSelected["title"] as? String
        } else {
            self.navigationItem.title = movieSelected["name"] as? String
        }
        
        showMovieDetails(movie: movieSelected)
        print(movieSelected as Any)
        
        // Do any additional setup after loading the view.
    }
    
    func showMovieDetails(movie: [String:Any]!) {
        if movie != nil {
            let baseURL = "https://image.tmdb.org/t/p/"
            let img_size = "original" //w342
            let backdropPath = movie["backdrop_path"] as! String
            let posterPath = movie["poster_path"] as! String
            let posterURLString = baseURL + img_size + posterPath
            let posterURL = URL(string: posterURLString)
            let backdropURLString = baseURL + img_size + backdropPath
            let backdropURL = URL(string: backdropURLString)
            
            backdropImage.af.setImage(withURL: backdropURL!)
            posterImage.af.setImage(withURL: posterURL!)
    
            if movie["title"] != nil {
                movieTitle.text = (movie["title"] as! String)
            } else {
                movieTitle.text = (movie["name"] as! String)
            }
            
            movieSynopsis.text = (movie["overview"] as! String)
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
