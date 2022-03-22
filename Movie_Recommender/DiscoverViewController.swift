//
//  DiscoverViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/14/22.
//

import UIKit
import AlamofireImage

class DiscoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    
    
    var trendingList = [[String:Any]]() // instance variable to save the data returned by API request
    var popularList = [[String:Any]]()
    var upcomingList = [[String:Any]]()
    var add_count = 0
    
//    var movie_categories = [[[String:Any]]]() //this dict will contain the names of movie categories as key and the movies arrays of dicts as value.
    var movie_categories = Array(repeating: [[String:Any]](), count: 3)
    //To create an array of specific size in Swift, use Array initialiser syntax and pass this specific size. We also need to pass the default value for these elements in the Array. To use Array initialiser syntax, we need to specify repeating or default value, and the count
    var movie_groups = ["Trending Movies", "Popular Movies", "Upcoming Movies"] //title of our sections
   
    @IBOutlet weak var tableView: UITableView!
    
//    // specifying that the search results will be displayed in the SearchResultsViewController VC
//    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
//
//    let searchResultsVC = SearchResultsViewController() //instance of search results view controller
//
//
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self //specifying the data will come from this view controller
        tableView.delegate = self

        // add the searchController as navigation item of this view controller
//        self.navigationItem.searchController = searchController
//        // allow users to see the search bar even when scrolling
//        self.navigationItem.hidesSearchBarWhenScrolling = false
//        self.searchController.searchResultsUpdater = self //the query for search will come from this view controller

        getTrendingMovies()
        getPopularMovies()
        getUpcomingMovies()
//        print("Hello")
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350 //height of tableView row
    }
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return movie_categories.count
    }
    
    //Header for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return movie_groups[section]
    }
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Table view cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableCell", for: indexPath) as! DiscoverTableCell
//        print("table view cell config")
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        return cell
    }
    
    // Setting the dataSource and delegate for the collection view cell to the table view controller so that the collection view can access and display the API data retrieved in this table view controller class
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        guard let tableViewCell = cell as? DiscoverTableCell else { return }
//        print("setting the data")
//        print(indexPath.section)
//        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
//
//
//    }
    
    // Sets the color of the section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .yellow
    }
    
    // MARK: - Collection view configuratiion
    
    // Sets the number of movies to display in each section of the table view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("IN COLLECTON VIEW NUM of MOVIES ")
//        print(collectionView.tag) //prints correct
        return movie_categories[collectionView.tag].count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionCell", for: indexPath) as! DiscoverCollectionCell

//        print("IN COLLECTON VIEW")
//        print(collectionView.tag)
        let movie_list = movie_categories[collectionView.tag]
        let movie = movie_list[indexPath.row]
        if movie["title"] != nil {
            cell.movieLabel.text = (movie["title"] as! String)
        } else {
            cell.movieLabel.text = (movie["name"] as! String)
        }
//      From TMDB doc: To build an image URL, you will need 3 pieces of data. The base_url, size and file_path. Simply combine them all and you will have a fully qualified URL.
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "original" //w342
        let poster_path = movie["poster_path"] as! String
        let imgURLString = (img_base_url + poster_size + poster_path)
        let imgURL = URL(string: imgURLString)
        
        cell.imageView.af.setImage(withURL: imgURL!) //URL is an optional object so force unwrap
        return cell
    }
    

    // MARK: - API Requests Methods
    func getTrendingMovies() {
        let api_key = "425089d4394daaa7a241ed4b96a4c194"
        let urlString = "https://api.themoviedb.org/3/trending/all/day?api_key=\(api_key)" //url String
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                print(dataDictionary)
                self.trendingList = dataDictionary["results"] as! [[String : Any]]
//                print(self.trendingList)
                self.movie_categories[0] = self.trendingList
                self.add_count = self.add_count + 1
                print("add_count trending: \(self.add_count)")
                // Reloads your table view data
                self.tableView.reloadData() //calls on the table view function
             }
        }
        task.resume()
        
    }
    

    func getPopularMovies() {
        let api_key = "425089d4394daaa7a241ed4b96a4c194"
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(api_key)" //url String
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                print(dataDictionary)
                self.popularList = dataDictionary["results"] as! [[String : Any]]
//                print(self.popularList)
                self.movie_categories[1] = self.popularList
                self.add_count = self.add_count + 1
//                print("add_count popular: \(self.add_count)")
                // Reloads your table view data
                self.tableView.reloadData() //calls on the table view function
             }
        }
        task.resume()
        
    }
    

    func getUpcomingMovies() {
        let api_key = "425089d4394daaa7a241ed4b96a4c194"
        let urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(api_key)" //url String
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                print(dataDictionary)
                self.upcomingList = dataDictionary["results"] as! [[String : Any]]
//                print(self.upcomingList)
                self.movie_categories[2] = self.upcomingList
                self.add_count = self.add_count + 1
//                print("add_count upcoming: \(self.add_count)")
                // Reloads your table view data
                self.tableView.reloadData() //calls on the table view function
             }
        }
        task.resume()
        
    }
    
    
    // MARK: - Search Bar methods
//    func updateSearchResults(for searchController: UISearchController) {
//        // makes sure query is not nil
//        let query = searchController.searchBar.text! as String
//        if !query.isEmpty {
//            getSearchResults(query: query)
//            let resultController = searchController.searchResultsController as! SearchResultsViewController
//            resultController.results = searchResults
//        }
//    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.resignFirstResponder() // dismisses keyboard
//    }
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        if !searchBar.text?.isEmpty {
//            let query = searchBar.text!
//            getSearchResults(query: query)
//
//        }
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
