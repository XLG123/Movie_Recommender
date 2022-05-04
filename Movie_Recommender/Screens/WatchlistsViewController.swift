//
//  WatchlistsViewController.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 3/22/22.
//
import UIKit

class WatchlistsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    // Create an array to store the movie lists
    @IBOutlet weak var tableV: UITableView!
    var movieLists = [MovieListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        //        navigationController?.navigationBar.backgroundColor = UIColor(red: 40/255.0, green: 60/255.0, blue: 84/255.0, alpha: 90) // Dark blue navigation bar color
        
        // Create the first object to be stored in the array
        let movielist1 = MovieListItem()
        movielist1.listTitle = "Watch List"
        movieLists.append(movielist1)
        
        // Create the second object to be stored in the array
        let movielist2 = MovieListItem()
        movielist2.listTitle = "Watched List"
        movieLists.append(movielist2)
        
        let movielist3 = MovieListItem()
        movielist3.listTitle = "Likes List"
        movieLists.append(movielist3)
        // Do any additional setup after loading the view.
        
        self.tableV.allowsSelection = true
        self.tableV.isUserInteractionEnabled = true
        
        self.tableV.delegate = self
        self.tableV.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Watchlists"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = ""
    }
    
    // MARK: - Showing the lists on Watchlists Screen
    
    // Get the number of lists in our array.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieLists.count
    }
    
    // Show each list to the screen.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movielistitem", for: indexPath)
        let movielist = movieLists[indexPath.row]
        
        configureText(for: cell, with: movielist)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectedVCId = ""
        if indexPath.row == 0 {
            selectedVCId = "WatchListVC"
        }else if indexPath.row == 1 {
            selectedVCId = "WatchedListVC"
        }else{
            selectedVCId = "LikesListVC"
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: selectedVCId)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func configureText(for cell: UITableViewCell, with item: MovieListItem) {
        let label = cell.viewWithTag(20) as! UILabel
        label.text = item.listTitle
    }
    
}
