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
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.rowHeight = 170

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
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        var query = searchBar.text!
        if !query.isEmpty {
            if query.contains(" ") {
                query = query.replacingOccurrences(of: " ", with: "%20") //spaces represented by %20 in the url
            }
            print("The search text is: \(searchBar.text!)")
            getSearchResults(query: query)
        }
    }        
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as! searchResultCell
        
        let movie = searchResults[indexPath.row]
        if movie["title"] != nil {
            cell.label.text = (movie["title"] as! String)
        }
        
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "original" //w342
        guard let poster_path = movie["poster_path"] as? String else {
            cell.movieImage.image = UIImage(named: "no_image_available")
            return cell
        } //if poster_path string is null, just return the cell
      
        let imgURLString = img_base_url + poster_size + poster_path
        let imgURL = URL(string: imgURLString)!
        cell.movieImage.af.setImage(withURL: imgURL) //URL is an optional object so force unwrap
        
        return cell
    }
  
    func getSearchResults(query: String) {
        let api_key = "425089d4394daaa7a241ed4b96a4c194"
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(api_key)&query=\(query)"
        guard let url = URL(string: urlString) else {
            //if not able to create a url from urlString, just return
            print("URL Error")
            return
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                   print(error.localizedDescription)
            } else if let data = data {
                   let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                //  print(dataDictionary)
                self.searchResults = dataDictionary["results"] as! [[String : Any]]
            }
            self.searchResultsTableView.reloadData()
        }
        task.resume()
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