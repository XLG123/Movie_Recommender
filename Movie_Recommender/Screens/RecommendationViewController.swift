//
//  RecommendationViewController.swift
//  Movie_Recommender
//
//  Created by S I on 5/7/22.
//

import UIKit
import AlamofireImage
import CoreData

class RecommendationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var movieRecIds = [Int]() //List of movie ids from REST API call
    var recResults = [[String:Any]]() //array of dictionaries obtained from API calls
    var networkCallDone = false
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 230
        
        for id in likedMovieIds{
            print(id)
        }
        //recResults.removeAll()
        //getMovieIdRecs()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Update list of recommendations
        //recResults.removeAll()
        //fetchStoredRecords()
        networkCallDone = false
        getMovieIdRecs()
        self.tableView.reloadData()
    }
    
    
    //Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("recResults count: \(recResults.count)")
        if (recResults.count == 0) && (networkCallDone == true) {
            print("NOTE: Not enough movies added to liked list")
            let rect = CGRect(origin: CGPoint(x: 0,y :40), size: CGSize(width: self.view.bounds.size.width-100, height: self.view.bounds.size.height))
            let insets = UIEdgeInsets(top: 5.0, left: 40.0, bottom: 5.0, right: 40.0)
            let messageLabel = UILabel(frame: rect.inset(by: insets))
            messageLabel.text = "Please add more movies to your liked list to obtain recommendations :)"
            messageLabel.textColor = UIColor.white
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
            messageLabel.sizeToFit()

            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
            print("RETURNED 0 IN NUMBEROFROWSINSECTION")
            return 0
        } else if ((recResults.count == 0) && (networkCallDone == false)) {
            print("NOT DONE LOADING")
            let rect = CGRect(origin: CGPoint(x: 0,y :40), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let insets = UIEdgeInsets(top: 5.0, left: 40.0, bottom: 5.0, right: 40.0)
            let messageLabel = UILabel(frame: rect.inset(by: insets))
            messageLabel.text = "Loading Recommendations..."
            messageLabel.textColor = UIColor.white
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
            messageLabel.sizeToFit()

            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
            print("STILL LOADING")
            return 0
        } else {
            return recResults.count
        }
    }
    
    //Content of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recMovieItem") as! RecommendCell
        let movie = recResults[indexPath.row] //as! [String : Any]
        
        //set title
        if (movie["title"] != nil){
            cell.movieTitle.text = (movie["title"] as! String)
        } else {
            cell.movieTitle.text = "Title Unavailable"
        }
        
        //set release date
        if (movie["release_date"]) != nil{
            cell.movieDate.text = (movie["release_date"] as! String)
        } else {
            cell.movieDate.text = ""
        }
        
        //set tagline
        if (movie["tagline"]) != nil{
            cell.movieTagLine.text = (movie["tagline"] as! String)
        } else {
            cell.movieTagLine.text = ""
        }
        
        //set image
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
    
    //Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.allowsSelection = false
        
        let movie = recResults[indexPath.row]
        self.performSegue(withIdentifier: "recToDetails", sender: movie)
    }
    
    // MARK: - REST API Request Method
    func getMovieIdRecs(){
        
        //Remove previous recommendations
        recResults.removeAll()
        
        let likedList: [Int64] = fetchStoredLikes()
        print("LIKED LIST: ")
        print(likedList)
        
        //If list is not empty
        if !likedList.isEmpty{
        
            //let urlString = "https://ml499model.herokuapp.com/movie?ids=16463"
            var urlString = "https://ml499model.herokuapp.com/movie?ids="
            for like in likedList {
                urlString += String(like)
                if (like != likedList[(likedList.count - 1)]) {
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
            //let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 80)
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
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
                
                //Remove movies that are already in watched and to watch list
                let wwList: [Int] = self.fetchStoredWW()
                for item in wwList {
                    //if the item is in recsList
                    if self.movieRecIds.contains(item){
                        //find id of item
                        if let index = self.movieRecIds.firstIndex(of: item) {
                            //remove item at index
                            self.movieRecIds.remove(at: index)
                        }
                    }
                }
                
                //TO-DO: Shorten list of recommendations
                for movieID in self.movieRecIds{
                    self.getSingleMovieDetails(movieId: movieID)
                }
                
                self.networkCallDone = true
                print("DONE LOADING")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            task.resume()
            
        }
        else {
            self.networkCallDone = true
            print("DONE LOADING")
        }
        
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
        print(urlString)
        
        //make requests
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                   print(error.localizedDescription)
            } else if let data = data {
                   let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let result = dataDictionary
                //if (self.recResults.contains(result) == false){
                self.recResults.append(result)
                //}
                
                //test
                print(result["title"] as! String)
                //print(self.recResults)
            }
            
            //Check with Tsering if this is good?
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
     
        let detailsVC = segue.destination as! MovieDetailsViewController //destination view controller
        detailsVC.movieSelected = sender as! [String:Any]?
        
        
    }
    
    
    
    //MARK: - Retrieve Lists from CoreData
    func fetchStoredLikes() -> [Int64]{
        var likedList = [Int64]()
        var likedItems = [LikeItem]()    // An array of liked movies.

        let ctx = appDel.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LikeItem")
        fetchRequest.predicate = NSPredicate(format: "isLike = true")

        do{
            likedItems = try ctx.fetch(fetchRequest) as! [LikeItem]
            print("Len \(likedItems.count)") // print out the list size.
            for item in likedItems {
                if !likedList.contains(item.id) {
                    likedList.append(item.id)
                }
            }
            //print(likedList)
            
        }catch{
            print("data might be corrupted, error: \(error)")
        }
        
        return likedList
    }
    
    
    //fetch watched and to watch list
    func fetchStoredWW() -> [Int]{
        var wwList = [Int]()
        var watcheditems = [WatchedItem]()
        var toWatchitems = [WatchItem]()

        let ctx = appDel.persistentContainer.viewContext
        do{
            
            //add watched items
            watcheditems = try ctx.fetch(WatchedItem.fetchRequest())
            print("Len \(watcheditems.count)") // print out the list size
            for item in watcheditems {
                if !wwList.contains(Int(item.id)) {
                    wwList.append(Int(item.id))
                }
            }
            
            //add to watch items
            toWatchitems = try ctx.fetch(WatchItem.fetchRequest())
            print("Len \(toWatchitems.count)") // print out the list size
            for item in toWatchitems {
                if !wwList.contains(Int(item.id)) {
                    wwList.append(Int(item.id))
                }
            }
            print(wwList)
        }catch{
            print("data might be corrupted, error: \(error)")
        }
        
        return wwList
    }

}
