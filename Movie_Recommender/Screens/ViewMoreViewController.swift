//
//  ViewMoreViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 4/4/22.
//

import UIKit
import AlamofireImage

class ViewMoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    //    var movies_list: [[String:Any]]?
    
    @IBOutlet var tableView: UITableView!
    
    var movies_list: [String: [[String:Any]]]? //a dict of an array of dictionaries
    var movies_category: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get the category name
        for (category, _) in movies_list! {
            //            print("category: \(category)")
            movies_category = category
        }
        self.navigationItem.title = movies_category
        print(movies_category!)
        print((movies_list?[movies_category!]?.count ?? 0) as Int)
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (movies_list?[movies_category!]?.count ?? 0) as Int
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewMoreCell") as! ViewMoreCell
        
        let movies = movies_list?[movies_category!]
        let movie = movies![indexPath.row]
        
        if movie["title"] != nil {
            cell.movieTitle.text = (movie["title"] as! String)
        } else {
            cell.movieTitle.text = (movie["name"] as! String)
        }
        
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185" //w342
        guard let poster_path = movie["poster_path"] as? String else {
            cell.movieImage.image = UIImage(named: "no_image_available")
            return cell
        } //if poster_path string is null, just return the cell
        
        let imgURLString = img_base_url + poster_size + poster_path
        let imgURL = URL(string: imgURLString)!
        cell.movieImage.af.setImage(withURL: imgURL) //URL is an optional object so force unwrap
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movies = movies_list?[movies_category!]
        let movie = movies![indexPath.row]
        performSegue(withIdentifier: "viewMoreToDetails", sender: movie)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let detailsVC = segue.destination as! MovieDetailsViewController //destination view controller
        detailsVC.movieSelected = sender as! [String:Any]? //sender is the movie that was selected by user. It's sent to the details VC
        
        //viewMoreToDetails
    }
    
    
}

