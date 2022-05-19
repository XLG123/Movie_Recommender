//
//  MovieDetailsViewController.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/29/22.
//

import UIKit
import AlamofireImage
import CoreData

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
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
    var storedItem: LikeItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if movieSelected["title"] != nil{
            self.navigationItem.title = movieSelected["title"] as? String
        } else{
            self.navigationItem.title = movieSelected["name"] as? String
        }
        
        showMovieDetails(movie: movieSelected)
        print(movieSelected as Any)
        providersCollectionView.delegate = self
        providersCollectionView.dataSource = self
        
        //Fetch Provider Details
        movieProvider()
       
        //watchlistButton.addAction(UIAction(title: "", handler: { (_) in
        // print("Default Action") }), for: .touchUpInside)
        watchlistButton.showsMenuAsPrimaryAction = true
        watchlistButton.menu = addMenuItems()
        
        //This function will maintain like unlike
        checkIfMovieAlreadyLiked()
    }
    
    // Check if a movie is liked or not from Core Data
    // If a user already liked a movie, update the corresponding button to a green thumbs up image
    // Otherwise, leave it as a white, unfilled thumbs up image
    func checkIfMovieAlreadyLiked(){
        let managedObjectContext = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LikeItem")
        fetchRequest.predicate = NSPredicate(format: "id = %d", movieSelected["id"] as! Int)
        
        var results: [LikeItem] = []
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [LikeItem]
            if results.count > 0 {
				// Update thumbs up button based on boolean value isLike
                self.storedItem = results[0]
                print("Movie exist")
                likeSelected = self.storedItem!.isLike
                if likeSelected! { // movie is liked, so change button to green filled thumbs up button
                    likeBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    likeBtn.tintColor = UIColor.init(red: 0/255, green: 255/255, blue: 0/255, alpha: 100)
                } else {  // movie isn't liked, so button should be plain unfilled thumbs up button
                    likeBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                    likeBtn.tintColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                }
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    //show details of movie
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
            } else {
                posterImage.image = UIImage(named: "no_image_available")
            }
            
            if let posterPath = movie["poster_path"] as? String {
                let posterURLString = baseURL + img_size + posterPath
                let posterURL = URL(string: posterURLString)
                posterImage.af.setImage(withURL: posterURL!)
            } else {
                posterImage.image = UIImage(named: "no_image_available")
            }
            
            
            if movie["title"] != nil {
                movieTitle.text = (movie["title"] as! String)
            } else {
                movieTitle.text = (movie["name"] as! String)
            }
            
            movieSynopsis.text = (movie["overview"] as! String)
			movieSynopsis.textAlignment = NSTextAlignment.justified
            
        }
    }
    
    // Return all the available streaming providers from the REST API call to TMDB
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
                
                // guard keyword is used for null safety.
                // If data result is non-empty, return the data result. Otherwise, return the message indicating no available services.
                guard let data_results = dataDictionary["results"] as? [String: [String: Any]] else {
                    print("data_results is nill")
                    print("NOT AVAILABLE ON ANY STREAMING SERVICES")
                    DispatchQueue.main.async {
                        self.providersCollectionView.reloadData()
                    }
                    return
                }
                // print(data_results)
                
                // Only Keeping the movies that are available in the US
                if data_results["US"]?["flatrate"] != nil {
                    let data_us = data_results["US"]!["flatrate"]! as! [[String: Any]]
                    // print(data_us)
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
    
    // Return the number of available streaming providers
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
        return movieProviders.count // providers.count
    }
    
    // Return the collection cell content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = providersCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! movieDetailsCollectionViewCell
        let dataDict = movieProviders[indexPath.item]
        
        //set provider name
        cell.movieProviderLabel.text = dataDict["provider_name"] as? String
        
        // Set provider image
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185"
        let logo_path = dataDict["logo_path"] as! String
        let imgURLString = (img_base_url + poster_size + logo_path)
        let imgURL = URL(string: imgURLString)
        
        cell.movieProviderImage.af.setImage(withURL: imgURL!)
        return cell
    }
    
    // When the thumbs up button is pressed, turns thumbs up image green.
    // If the user clicks on the thumbs up button again, switch to a unfilled white thumbs up image.
    @IBAction func likeBtnPress(_ sender: UIButton) {
        if let _ = likeSelected   {
            likeSelected = !likeSelected!
            if likeSelected! {
                likeBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                likeBtn.tintColor = UIColor.init(red: 0/255, green: 255/255, blue: 0/255, alpha: 100)
				addUpdateCurrentMovie(isLike: likeSelected!)
            } else{ // user unliked, meaning clicked like button when it was already liked
                if let movieIndex = likedMovieIds.firstIndex(of: movieSelected["id"] as! Int64) {
                    if movieIndex < likedMovieIds.count {
						addUpdateCurrentMovie(isLike: likeSelected!)
                        likedMovieIds.remove(at: movieIndex)
						deleteFromLikesList(indexAt: movieIndex)
                    }
                }
                likeBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                likeBtn.tintColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
				
            }
        } else{ // like button was't already pressed, so change it to filled thumbs up button
            likeSelected = true
            likeBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            likeBtn.tintColor = UIColor.init(red: 0/255, green: 255/255, blue: 0/255, alpha: 100)
			addUpdateCurrentMovie(isLike: likeSelected!)
        }
    }
    
    // Insert movie to the Likes List
    // If a movie is already in the list, updates corresponding title or movie picture if its' changed, otherwise, keep it the same way
    // Else, insert the new movie item to the end of the list
    func addUpdateCurrentMovie(isLike:Bool){
        var item : LikeItem!
		if let x = storedItem {
            // if an item is already added then we need to update the details (such as title & image)
            item = x
        }else{ // else, insert new item to the end of the list
            item = LikeItem(context: appDel.persistentContainer.viewContext)
			self.addToWatchedList2()
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
        appDel.saveContext() // Update the current CoreData Stack
        checkIfMovieAlreadyLiked()
        
    }
    
    
    // Created two list items(Watch List and Watched List) in watchlists Button on Movie Detail Screen.
    func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Watch List", handler: {(_) in
                print("Watch List")
                // add selected item to watchlist entity
                self.addToWatchList()
            }),
            
            UIAction(title: "Watched List", handler: {(_) in
                print("Watched List")
                // add selected item to watchedlist entity
                self.addToWatchedList1()
            }),
        ])
        
        return menuItems
    }
    
    // Add a movie to Watch List if it's not in Watch List.
    func addToWatchList(){
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results1: [WatchItem] = []
        var results2: [WatchedItem] = []
        
        let fetchRequest1 = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        let idVal = movieSelected["id"] as! Int64
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        
//		A notification for a successful attempt of adding movie to Watch List.
        let watchNotifySuccess = UIAlertController (title: "You successfully added the movie to Watch List", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelwatchNotify = UIAlertAction(title: "Done", style: UIAlertAction.Style.cancel, handler: nil)
               watchNotifySuccess.addAction(cancelwatchNotify)
 
//		A notification for an unsuccessful attempt.
//		Case 1: movie is already in Watch List.
        let watchNotifyFailure1 = UIAlertController (title: "Movie is already in Watch List", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelwatchNotify1 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
               watchNotifyFailure1.addAction(cancelwatchNotify1)
        
//		Case 2: movie is in Watched List.
        let watchNotifyFailure2 = UIAlertController (title: "Movie is in Watched List", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelwatchNotify2 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
               watchNotifyFailure2.addAction(cancelwatchNotify2)
        
        // filtering entities with id
        // check for the specific movie id in the entity
        fetchRequest1.predicate = NSPredicate(format: "id == %d",idVal)
        fetchRequest2.predicate = NSPredicate(format: "id == %d",idVal)
        do {
            results1 = try managedObjectContext.fetch(fetchRequest1) as! [WatchItem]
            results2 = try managedObjectContext.fetch(fetchRequest2) as! [WatchedItem]
            
            // If selected item is not found in WatchItem, then create an entity with details.
            if results1.count == 0 && results2.count == 0{
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
                self.present(watchNotifySuccess, animated:true, completion: nil)
                appDel.saveContext() // save selected movie item to CoreData
            }
            else if results1.count != 0 && results2.count == 0{
                self.present(watchNotifyFailure1, animated:true, completion: nil)
            }
            else if results1.count == 0 && results2.count != 0{
                self.present(watchNotifyFailure2, animated:true, completion: nil)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    // Add a movie to Watched List if it's not in Watched List.
    func addToWatchedList1(){
		
		//get current time
		let currentTime = Date();
		let df = DateFormatter();
		df.dateFormat = "yyyy-MM-dd";
		let dateString = df.string(from: currentTime);
		//print(dateString)
		
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results1: [WatchedItem] = []
        var results2: [WatchItem] = []
        
        let fetchRequest1 = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        let idVal = movieSelected["id"] as! Int64
        
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        
//		A notification for a successful attempt of adding movie to Watched List.
        let watchedNotifySuccess = UIAlertController (title: "You successfully added the movie to Watched List", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelwatchedNotify = UIAlertAction(title: "Done", style: UIAlertAction.Style.cancel, handler: nil)
               watchedNotifySuccess.addAction(cancelwatchedNotify)

//		A notification for an unsuccessful attempt.
//		Case 1: movie is already in Watched List.
        let watchedNotifyFailure1 = UIAlertController (title: "Movie is already in Watched List", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelwatchedNotify1 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
               watchedNotifyFailure1.addAction(cancelwatchedNotify1)
        
//		Case 2: movie is in Watch List.
        let watchedNotifyFailure2 = UIAlertController (title: "Movie is in Watch List", message: nil, preferredStyle: UIAlertController.Style.alert)
        let cancelwatchedNotify2 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
               watchedNotifyFailure2.addAction(cancelwatchedNotify2)
		
//		Case 3: movie is not released yet.
		let watchedNotifyFailure3 = UIAlertController (title: "Movie is not released yet.", message: nil, preferredStyle: UIAlertController.Style.alert)
		let cancelwatchedNotify3 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
			   watchedNotifyFailure3.addAction(cancelwatchedNotify3)
		
        
        // filtering entities with id
        // check for the specific movie id in the entity
        fetchRequest1.predicate = NSPredicate(format: "id == %d",idVal)
        fetchRequest2.predicate = NSPredicate(format: "id == %d",idVal)
        do {
            results1 = try managedObjectContext.fetch(fetchRequest1) as! [WatchedItem]
            results2 = try managedObjectContext.fetch(fetchRequest2) as! [WatchItem]
            
			let release_date = movieSelected["release_date"] as! String
			
            // If selected item is not found in WatchedItem and the selected movie is already released, then create an entity with details.
			if results1.count == 0 && results2.count == 0 && release_date <= dateString{
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
                self.present(watchedNotifySuccess, animated:true, completion:nil)
                
                appDel.saveContext() // save selected movie item to CoreData
            }
            else if results1.count != 0 && results2.count == 0{
                self.present(watchedNotifyFailure1, animated:true, completion:nil)
            }
            else if results1.count == 0 && results2.count != 0 {
                self.present(watchedNotifyFailure2, animated:true, completion:nil)
            }
			else if release_date > dateString {
				self.present(watchedNotifyFailure3, animated:true, completion:nil)
			}
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
	
	//	For Like button only.
	//	Remove notifications when like button is clicked.
	//	A duplicated version of addToWatched1() func, but without the notifications.
	func addToWatchedList2(){
		
		//get current time
		let currentTime = Date();
		let df = DateFormatter();
		df.dateFormat = "yyyy-MM-dd";
		let dateString = df.string(from: currentTime);
		//print(dateString)
		
		let managedObjectContext = appDel.persistentContainer.viewContext
		var results1: [WatchedItem] = []
		var results2: [WatchItem] = []
		
		let fetchRequest1 = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
		let idVal = movieSelected["id"] as! Int64
		
		let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
		
		// filtering entities with id
		// check for the specific movie id in the entity
		fetchRequest1.predicate = NSPredicate(format: "id == %d",idVal)
		fetchRequest2.predicate = NSPredicate(format: "id == %d",idVal)
		do {
			results1 = try managedObjectContext.fetch(fetchRequest1) as! [WatchedItem]
			results2 = try managedObjectContext.fetch(fetchRequest2) as! [WatchItem]
			
			let release_date = movieSelected["release_date"] as! String
			
			// If selected item is not found in WatchedItem and the selected movie is already released, then create an entity with details.
			if results1.count == 0 && results2.count == 0 && release_date <= dateString{
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
				appDel.saveContext() // save selected movie item to CoreData
			}
		}
		catch {
			print("error executing fetch request: \(error)")
		}
		
	}
	
	func deleteFromLikesList(indexAt: Int) {
		let ctx = appDel.persistentContainer.viewContext
		ctx.delete(storedItem!)
		appDel.saveContext()
	}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


