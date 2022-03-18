//
//  DiscoverViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/14/22.
//

import UIKit


class DiscoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
  
    var trendingList = [[String:Any]]() // instance variable to save the data returned by API request
        
    var movie_groups = ["Trending Movies", "Popular Movies", "Upcoming Movies"] //title of our sections
    
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self //specifying the data will come from this view controller
        tableView.delegate = self
        getTrendingMovies()
        print("Hello")
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - TableView methods
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350 //height of tableView row
    }
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return movie_groups.count
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
        
        return cell
    }
    
    // Setting the dataSource and delegate for the collection view cell to the table view controller so that the collection view can access and display the API data retrieved in this table view controller class
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? DiscoverTableCell else { return }
        print(indexPath.row)

        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
    }
    
    // Sets the color of the section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .yellow
    }
    
    // MARK: - Collection view configuratiion
    
    // Sets the number of movies to display in each section of the table view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("IN COLLECTON VIEW")
//        print(collectionView.tag)
        print(self.trendingList)
        // return arrayOfCategoryObjects[collectionView.tag].movies.count
        return trendingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionCell", for: indexPath) as! DiscoverCollectionCell
//        print(collectionView.tag)
        
        print("IN COLLECTON VIEW")
        cell.movieLabel.text = (trendingList[collectionView.tag]["title"] as! String)
        
        cell.imageView.image = UIImage(named: "spiderman")
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
                //print(self.trendingList)
                // Reloads your table view data
                self.tableView.reloadData() //calls on the table view function
             }
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
