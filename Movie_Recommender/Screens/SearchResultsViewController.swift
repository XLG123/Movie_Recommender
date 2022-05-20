//
//  SearchResultsViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/22/22.
//

import UIKit
import AlamofireImage

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var searchResults = [[String:Any]]() //array of dictionaries
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // Below code taken from website https://mobikul.com/customise-the-uisearchbar-in-swift/
        //UISearchBar contains the UITextField which can be identified through key “searchField”. Therefore we can access the UITextField through the key and perform necessary changes with it.
        let searchTextfield = searchBar.value(forKey: "searchField") as? UITextField
        searchTextfield!.textColor = UIColor.white //makes text color of search bar white
        // Above code was taken from online website
        
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.rowHeight = 230
        
        // Do any additional setup after loading the view.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        let query = searchBar.text!
        //        if !query.isEmpty {
        //            print("The search text is: \(searchBar.text!)")
        //            getSearchResults(query: query)
        //        }
        searchBar.resignFirstResponder() //dismisses the keyboard when search button is clicked
    }
    
    /*
     This function gets the text user enters in the search text field and calls the getSearchResults()
     with the query.
     */
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        var query = searchBar.text!
        if !query.isEmpty {
            if query.contains(" ") {
                query = query.replacingOccurrences(of: " ", with: "%20") //spaces represented by %20 in the url
            }
            getSearchResults(query: query)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder() // dismisses keyboard
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as! searchResultCell
        
        let movie = searchResults[indexPath.row]
        
        //set title
        if movie["title"] != nil {
            cell.label.text = (movie["title"] as! String)
        }
        
        //set release date
        if (movie["release_date"]) != nil{
            cell.movieDate.text = (movie["release_date"] as! String)
        } else {
            cell.movieDate.text = ""
        }
        
        //set overview
        if (movie["overview"]) != nil{
            cell.movieTagLine.text = (movie["overview"] as! String)
        } else {
            cell.movieTagLine.text = ""
        }
        
        //set movie image
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
    
    // This function is called when the user selects an item(movie) in the table View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = searchResults[indexPath.row]
        print(movie)
        self.performSegue(withIdentifier: "searchToDetails", sender: movie)
    }
    
    
    // MARK - API Call
    
    /*
     This function makes an API Call to the TMDB API with the search query, and loads the tableview
     with the search results returned.
     */
    func getSearchResults(query: String) {
        let api_key = "425089d4394daaa7a241ed4b96a4c194"
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(api_key)&query=\(query)"
        guard let url = URL(string: urlString) else {
            //if not able to create a url from urlString, just return
            print("URL Error")
            return
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.searchResults = dataDictionary["results"] as! [[String : Any]]
            }
            
            DispatchQueue.main.async {
                self.searchResultsTableView.reloadData()
            }
        }
        task.resume()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let detailsVC = segue.destination as! MovieDetailsViewController
        detailsVC.movieSelected = sender as! [String:Any]?// note that the movie was passed as argument for sender
        
    }
    
}
