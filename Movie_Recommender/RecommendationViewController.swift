//
//  RecommendationViewController.swift
//  Movie_Recommender
//
//  Created by S I on 4/26/22.
//

//TODO: set up segue to Movie Details
//TODO: REST API calls
//TODO: set secondary label with more content

import UIKit
import AlamofireImage

class RecommendationViewController: UITableViewController{
    
    var movieRecIds = [Int]() //List of movie ids from REST API call
    var likedList = [Int]() //List of movies from watch list
    var watchedList = [Int]() //will implement later but remove these ids from likedList
    
    var recResults = [[String:Any]]() //array of dictionaries obtained from API calls
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //NavBar
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Artificially add movies to movieRecIds
        //movieRecIds.append(32673) //The Kingdom of the Fairies
        //movieRecIds.append(70512) //Dante's Inferno
        
        likedList.append(11674) //101 Dalmatians
        likedList.append(25694) //Alice in Wonderland
        likedList.append(438561) //Spiderman
        likedList.append(87442) //Sonic Christmas Blast
        

        //Update list of recommendations
        updateRESTList()
        updateTMDBList()
        tableView.reloadData()
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        //Update list of recommendations
//        updateRESTList()
//        updateTMDBList()
//        self.tableView.reloadData()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Update list of recommendations
        updateRESTList()
        updateTMDBList()
        self.tableView.reloadData()
    }

    
    
    // MARK: - Table view data source
    
    //set # of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recResults.count //Length of recommendations
    }

    // define reusable cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recMovieItem") as! ViewMoreCell
        
        let movie = recResults[indexPath.row] //as! [String : Any]
        
        if (movie["title"] != nil){
            cell.movieTitle.text = (movie["title"] as! String)
        } else {
            cell.movieTitle.text = "Title Error"
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
    
    // select row - TODO: Need to finish implementing
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = recResults[indexPath.row]
        self.performSegue(withIdentifier: "recToDetails", sender: movie)
    }
    
    // MARK: - REST API Requests Methods
    func getMovieIdRecs(likes: [Int]){
        //let urlString = "https://ml499model.herokuapp.com/movie?ids=16463"
        var urlString = "https://ml499model.herokuapp.com/movie?ids="
        for like in likes {
            urlString += String(like)
            if (like != likes[(likes.count - 1)]) {
                urlString += ","
            }
        }
        
        //Test URL
        print("TEST LIST OF IDS IN URL")
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            //test if successful url
            print("URL Error")
            return
        }
        
        //make requests
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 180)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                   print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let result = dataDictionary["recommendation"] as! [Int]
                self.movieRecIds = result

                print("TEST RECOMMENDATION LIST")
                //print(result)
                for id in self.movieRecIds{
                    print(id)
                }
                
                print("NUMBER OF MOVIES")
                print(self.movieRecIds.count)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    // MARK: - TMDB API Requests Methods
    func getSingleMovieDetails(movieId: Int){
        let api_key = "425089d4394daaa7a241ed4b96a4c194"
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(api_key)"
        guard let url = URL(string: urlString) else {
            //test if successful url
            print("URL Error")
            return
        }
        
        //make requests
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                   print(error.localizedDescription)
            } else if let data = data {
                   let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let result = dataDictionary as! [String : Any]
                self.recResults.append(result)
                
                //test
                print(result["title"] as! String)
                //print(self.recResults)
            }
            
            //Check with Tsering if this is good?
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }
        task.resume()
    }
    
    func updateRESTList(){
        //updates movieRecIds to list of recommended movie id
        getMovieIdRecs(likes: likedList)
        
    }
    
    func updateTMDBList(){
        //Updates recResults with all the tmdb api content
        if movieRecIds.count != 0 {
            for i in 0..<20{
                getSingleMovieDetails(movieId: movieRecIds[i])
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    //MARK: - Navigation
    /*
     //Segue to Movie details screen when a Movie is selected
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
         let detailsVC = segue.destination as! MovieDetailsViewController
         detailsVC.movieSelected = sender as! [String:Any]?// note that the movie was passed as argument for sender
         
     }
    */

}
