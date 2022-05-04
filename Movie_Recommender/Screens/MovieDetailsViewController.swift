//
//  MovieDetailsViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/29/22.
//

import UIKit
import AlamofireImage
import CoreData

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieSynopsis: UILabel!
    @IBOutlet weak var providersCollectionView: UICollectionView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var watchlistButton: UIButton!
    
    var likeSelected:Bool?;
    var movieSelected: [String:Any]!
    var movieProviders: [[String: Any]]!
    var networkCallDone = false
    let api_key = "f6fcc9cb0a418a35f977477bc4f8f0af"
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var storedItem:LikeItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if movieSelected["title"] != nil {
            self.navigationItem.title = movieSelected["title"] as? String
        } else {
            self.navigationItem.title = movieSelected["name"] as? String
        }
        
        showMovieDetails(movie: movieSelected)
        print(movieSelected as Any)
        providersCollectionView.delegate = self
        providersCollectionView.dataSource = self
        movieProvider()
        watchlistButton.showsMenuAsPrimaryAction = true
        watchlistButton.menu = addMenuItems()
        
        //This function will maintain like unlike
        checkIfMovieAlreadyLiked()
    }
    
    func checkIfMovieAlreadyLiked(){
        let managedObjectContext = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LikeItem")
        fetchRequest.predicate = NSPredicate(format: "id = %d", movieSelected["id"] as! Int)
        
        var results: [LikeItem] = []
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [LikeItem]
            if results.count > 0 {
                //if selected record already liked then take that rcord and update color and update icon based on isLike flag
                self.storedItem = results[0]
                print("Movie exist")
                likeSelected = self.storedItem!.isLike
                if likeSelected! {
                    likeBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                }else{
                    likeBtn.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
                }
                likeBtn.tintColor = UIColor.red
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    func showMovieDetails(movie: [String:Any]!) {
        if movie != nil {
            let baseURL = "https://image.tmdb.org/t/p/"
            let img_size = "w185"
            // some movies don't have backdrop images so make sure to check
            if let backdropPath = movie["backdrop_path"] as? String {
                let backdrop_img_size = "w500"
                let backdropURLString = baseURL + backdrop_img_size + backdropPath
                let backdropURL = URL(string: backdropURLString)
                backdropImage.af.setImage(withURL: backdropURL!)
            }
            
            let posterPath = movie["poster_path"] as! String
            let posterURLString = baseURL + img_size + posterPath
            let posterURL = URL(string: posterURLString)
            posterImage.af.setImage(withURL: posterURL!)
            
            if movie["title"] != nil {
                movieTitle.text = (movie["title"] as! String)
            } else {
                movieTitle.text = (movie["name"] as! String)
            }
            
            movieSynopsis.text = (movie["overview"] as! String)
            
        }
    }
    
    func movieProvider() {
        //let movie_id: String = String(movieSelected["id"])
        let movie_id = movieSelected["id"] as! Int
        let urlString="https://api.themoviedb.org/3/movie/\(movie_id)/watch/providers?api_key=\(api_key)"
        let url = URL(string: urlString)!
        let request = URLRequest(url:url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession.shared
        let task = session.dataTask(with:request){(data, response, error) in
            self.networkCallDone = true
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try!JSONSerialization.jsonObject(with:data,options:[])as![String:Any]
                
                guard let data_results = dataDictionary["results"] as? [String: [String: Any]] else {
                    print("data_results is nill")
                    print("NOT AVAILABLE ON ANY STREAMING SERVICES")
                    DispatchQueue.main.async {
                        self.providersCollectionView.reloadData()
                    }
                    return
                }
                
                //                print(data_results)
                if data_results["US"]?["flatrate"] != nil {
                    let data_us = data_results["US"]!["flatrate"]! as! [[String: Any]]
                    //print(data_us)
                    self.movieProviders = data_us
                    print(self.movieProviders!)
                   
                } else {
                    print("NOT AVAILABLE ON ANY STREAMING SERVICES")
                }
                DispatchQueue.main.async {
                    self.providersCollectionView.reloadData()
                }
            }
            
        }
        
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if movieProviders == nil || movieProviders.count == 0{
            if networkCallDone {
                let lbl = UILabel(frame: collectionView.frame)
                lbl.text = "No Streaming Services"
                lbl.textAlignment = .center
                lbl.textColor = UIColor.white
                collectionView.backgroundView = lbl
            }
            return 0
        }
        collectionView.backgroundView = nil
        return movieProviders.count//providers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = providersCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! movieDetailsCollectionViewCell
        let dataDict = movieProviders[indexPath.item]
        
        //set provider name
        cell.movieProviderLabel.text = dataDict["provider_name"] as? String
        
        // this is to set the provider image
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185"
        let logo_path = dataDict["logo_path"] as! String
        let imgURLString = (img_base_url + poster_size + logo_path)
        let imgURL = URL(string: imgURLString)
                
        cell.movieProviderImage.af.setImage(withURL: imgURL!)
        return cell
    }
    
    @IBAction func likeBtnPress(_ sender: UIButton) {
        if let _ = likeSelected   {
            likeSelected = !likeSelected!
            if likeSelected! {
                likeBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }else{
                likeBtn.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            }
        }else{
            likeSelected = true
            likeBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        addUpdateCurrentMovie(isLike: likeSelected!)
        likeBtn.tintColor = UIColor.red
    }
    
    func addUpdateCurrentMovie(isLike:Bool){
        var item : LikeItem!
        if let x = storedItem {
            //if item is already added then we need to update it only
            item = x
        }else{
            item = LikeItem(context: appDel.persistentContainer.viewContext)
        }
        
        item.adult = movieSelected["adult"] as! Bool
        item.backdrop_path = movieSelected["backdrop_path"] as? String
        item.id = movieSelected["id"] as! Int64
        item.isLike = isLike
        item.media_type = movieSelected["media_type"] as? String
        item.original_language = movieSelected["original_language"] as? String
        item.original_title = movieSelected["original_title"] as? String
        item.overview = movieSelected["overview"] as? String
        item.popularity = movieSelected["popularity"] as! Double
        item.poster_path = movieSelected["poster_path"] as? String
        item.release_date = movieSelected["release_date"] as? String
        item.title = movieSelected["title"] as? String
        item.video = movieSelected["video"] as! Bool
        item.vote_average = movieSelected["vote_average"] as! Double
        item.vote_count = movieSelected["vote_count"] as! Int16
        
        appDel.saveContext()
        
        checkIfMovieAlreadyLiked()
        
    }
    
    func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Watch List", handler: {(_) in
                print("Watch List")
                //add selected item in watchlist entity
                self.addToWatchList()
            }),
            
            UIAction(title: "Watched List", handler: {(_) in
                print("Watched List")
                //add selected item in watchedlist entity
                self.addToWatchedList()
            }),
        ])
        
        return menuItems
    }
    
    func addToWatchList(){
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        let idVal = movieSelected["id"] as! Int64
        //filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",idVal)
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [WatchItem]
            if results.count == 0 {
                //selected item not saved in WatchedItem so create entity with details
                let item = WatchItem(context: appDel.persistentContainer.viewContext)
                
                item.adult = movieSelected["adult"] as! Bool
                item.backdrop_path = movieSelected["backdrop_path"] as? String
                item.id = movieSelected["id"] as! Int64
                item.media_type = movieSelected["media_type"] as? String
                item.original_language = movieSelected["original_language"] as? String
                item.original_title = movieSelected["original_title"] as? String
                item.overview = movieSelected["overview"] as? String
                item.popularity = movieSelected["popularity"] as! Double
                item.poster_path = movieSelected["poster_path"] as? String
                item.release_date = movieSelected["release_date"] as? String
                item.title = movieSelected["title"] as? String
                item.video = movieSelected["video"] as! Bool
                item.vote_average = movieSelected["vote_average"] as! Double
                item.vote_count = movieSelected["vote_count"] as! Int16
                
                appDel.saveContext()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    
    func addToWatchedList(){
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchedItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        let idVal = movieSelected["id"] as! Int64
        fetchRequest.predicate = NSPredicate(format: "id == %d",idVal)
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [WatchedItem]
            if results.count == 0 {
                //selected item not saved in WatchedItem so create entity with details
                let item = WatchedItem(context: appDel.persistentContainer.viewContext)
                
                item.adult = movieSelected["adult"] as! Bool
                item.backdrop_path = movieSelected["backdrop_path"] as? String
                item.id = movieSelected["id"] as! Int64
                item.media_type = movieSelected["media_type"] as? String
                item.original_language = movieSelected["original_language"] as? String
                item.original_title = movieSelected["original_title"] as? String
                item.overview = movieSelected["overview"] as? String
                item.popularity = movieSelected["popularity"] as! Double
                item.poster_path = movieSelected["poster_path"] as? String
                item.release_date = movieSelected["release_date"] as? String
                item.title = movieSelected["title"] as? String
                item.video = movieSelected["video"] as! Bool
                item.vote_average = movieSelected["vote_average"] as! Double
                item.vote_count = movieSelected["vote_count"] as! Int16
                
                appDel.saveContext()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
        }
    
    }


