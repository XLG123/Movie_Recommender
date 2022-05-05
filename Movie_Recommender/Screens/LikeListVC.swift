//
//  LikeListVC.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 04/16/22.
//

import UIKit
import AlamofireImage
import CoreData

var likedMovieIds = [Int64]() // An array of the liked movie ids.

class LikeListVC: UIViewController {
    
    @IBOutlet weak var tableV: UITableView!
    var items = [LikeItem]()    // An array of liked movies.
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Likes List"
        fetchStoredRecords() // Fetch all data once the view loads.
    }
    
    // Fetch all liked movies from CoreData.
    func fetchStoredRecords(){
        let ctx = appDel.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LikeItem")
        fetchRequest.predicate = NSPredicate(format: "isLike = true")
        
        do{
            items = try ctx.fetch(fetchRequest) as! [LikeItem]
            print("Len \(items.count)") // print out the list size.
            for item in items {
                if !likedMovieIds.contains(item.id) {
                    likedMovieIds.append(item.id)
                }
            }
            print(likedMovieIds)
            
            self.tableV.reloadData()
        }catch{
            print("data might be corrupted, error: \(error)")
        }
    }
}

// A table view that contains a list of liked movies based on the user preferences.
extension LikeListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if list size is 0, show a label with message "No Data", then return 0.
        if items.count == 0 {
            let lbl = UILabel(frame: tableView.frame)
            lbl.text = "No Data"
            lbl.textAlignment = .center
            tableV.backgroundView = lbl
            return items.count
            
        }
        tableV.backgroundView = nil
        return items.count // otherwise, return the list size.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MovieTVC
        cell.selectionStyle = .none
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185" //w342
        let imgURLString = (img_base_url + poster_size + item.poster_path!)
        let imgURL = URL(string: imgURLString)
        
        cell.imgV.af.setImage(withURL: imgURL!)
        cell.titleLbl.text = item.title
        cell.firstBtn.tag = indexPath.row
        cell.secondBtn.tag = indexPath.row
        cell.firstBtn.addTarget(self, action: #selector(moveToWatch(sender:)), for: .touchUpInside)
        cell.secondBtn.addTarget(self, action: #selector(moveToWatched(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    
    // Add a movie to Watch List.
    @objc func moveToWatch(sender:UIButton){
        
        let clickedItem = items[sender.tag]
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        
        // filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [WatchItem]
            
            var item : WatchItem!
            if results.count == 0 {
                item = WatchItem(context: appDel.persistentContainer.viewContext)
            }else{
                item = results[0]
            }
            item.adult = clickedItem.adult
            item.backdrop_path = clickedItem.backdrop_path
            item.id = clickedItem.id
            item.media_type = clickedItem.media_type
            item.original_language = clickedItem.original_language
            item.original_title = clickedItem.original_title
            item.overview = clickedItem.overview
            item.popularity = clickedItem.popularity
            item.poster_path = clickedItem.poster_path
            item.release_date = clickedItem.release_date
            item.title = clickedItem.title
            item.video = clickedItem.video
            item.vote_average = clickedItem.vote_average
            item.vote_count = clickedItem.vote_count
            
            appDel.saveContext()
            
            // Remove the movie from Watched List if it's found there.
            deleteFromWatched(idStr: NSNumber(value: item.id).intValue)

        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    // Add a movie to Watched List.
    @objc func moveToWatched(sender:UIButton){
        
        let clickedItem = items[sender.tag]
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchedItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        
        // filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [WatchedItem]
            
            var item : WatchedItem!
            if results.count == 0 {
                item = WatchedItem(context: appDel.persistentContainer.viewContext)
            }else{
                item = results[0]
            }
            item.adult = clickedItem.adult
            item.backdrop_path = clickedItem.backdrop_path
            item.id = clickedItem.id
            item.media_type = clickedItem.media_type
            item.original_language = clickedItem.original_language
            item.original_title = clickedItem.original_title
            item.overview = clickedItem.overview
            item.popularity = clickedItem.popularity
            item.poster_path = clickedItem.poster_path
            item.release_date = clickedItem.release_date
            item.title = clickedItem.title
            item.video = clickedItem.video
            item.vote_average = clickedItem.vote_average
            item.vote_count = clickedItem.vote_count
            
            appDel.saveContext()
            
            deleteFromWatch(idStr: NSNumber(value: item.id).intValue)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    // Remove movie from Watch List.
    func deleteFromWatch(idStr:Int){
        let ctx = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        
        // filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",idStr)
        do {
            let results: [WatchItem] = try ctx.fetch(fetchRequest)  as! [WatchItem]
            if results.count > 0 {
                //if movie item not found in CoreData Stack, then create a new instance of it.
                let item : WatchItem = results[0]
                ctx.delete(item)
                appDel.saveContext()
                fetchStoredRecords()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    // Remove movie from Watched List.
    func deleteFromWatched(idStr:Int){
        let ctx = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        
        // filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",idStr)
        do {
            let results: [WatchedItem] = try ctx.fetch(fetchRequest)  as! [WatchedItem]
            if results.count > 0 {
                let item : WatchedItem = results[0]
                ctx.delete(item)
                appDel.saveContext()
                fetchStoredRecords()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
}
