//
//  WatchedListVC.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 04/26/22.
//

import UIKit
import AlamofireImage
import CoreData

var watchedMovieIds = [Int64]() // An array of the watched movie ids.

class WatchedListVC: UIViewController {
    
    
    @IBOutlet weak var tableV: UITableView!
    var items = [WatchedItem]() // An array of the watched movie ids.
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Watched List"
        fetchStoredRecords()    // Fetch all data once the view loads.
    }
    
    // Fetch all watched movies from CoreData.
    func fetchStoredRecords(){
        let ctx = appDel.persistentContainer.viewContext
        do{
            items = try ctx.fetch(WatchedItem.fetchRequest())
            print("Len \(items.count)") // print out the list size
            for item in items {
                if !watchedMovieIds.contains(item.id) {
                    watchedMovieIds.append(item.id)
                }
            }
            print(watchedMovieIds)
            
            self.tableV.reloadData()
        }catch{
            print("data might be corrupted, error: \(error)")
        }
    }
}

// A table view that contains a list of watched movies.
extension WatchedListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if list size is 0, show a label with message "No Data", then return 0.
        if items.count == 0 {
            let lbl = UILabel(frame: tableView.frame)
            lbl.text = "No Data"
            lbl.textColor = UIColor(named: "white")
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
        cell.firstBtn.addTarget(self, action: #selector(moveToLike(sender:)), for: .touchUpInside)
        cell.secondBtn.addTarget(self, action: #selector(moveToWatch(sender:)), for: .touchUpInside)
        
        // Buttons receive null values when a movie is deleted from CoreData, and creash the app.
        // let imgV = cell!.viewWithTag(1) as! UIImageView
        // imgV.af.setImage(withURL: imgURL!)
        //
        // let lbl = cell!.viewWithTag(2) as! UILabel
        // lbl.text = item.title
        //
        // let likeBtn = cell!.viewWithTag(3) as! UIButton
        // likeBtn.tag = indexPath.row
        // likeBtn.addTarget(self, action: #selector(moveToLike(sender:)), for: .touchUpInside)
        //
        // let watchBtn = cell!.viewWithTag(4) as! UIButton
        // watchBtn.tag = indexPath.row
        // watchBtn.addTarget(self, action: #selector(moveToWatch(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
            deleteItem(indexNo: indexPath.row)
        }
    }
    
    // Delete a movie from list and remove the item from CoreData.
    func deleteItem(indexNo:Int){
        if (indexNo < watchedMovieIds.count) {
            watchedMovieIds.remove(at: indexNo)
        }
        let ctx = appDel.persistentContainer.viewContext
        ctx.delete(items[indexNo])
        appDel.saveContext()
        fetchStoredRecords()
    }
    
    // Add the movie to like list.
    @objc func moveToLike(sender:UIButton){
        
        let clickedItem = items[sender.tag]
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [LikeItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LikeItem")
        
        // filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        do {
            results = try managedObjectContext.fetch(fetchRequest) as! [LikeItem]
            
            var item : LikeItem!
            if results.count == 0 {
                item = LikeItem(context: managedObjectContext)
                item.isLike = true // Set isLike to true
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
            
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    // Move the movie to Watch List.
    @objc func moveToWatch(sender:UIButton){
        
        let clickedItem = items[sender.tag]
        let ctx = appDel.persistentContainer.viewContext
        var results: [WatchItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        
        // filtering entities
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        do {
            results = try ctx.fetch(fetchRequest) as! [WatchItem]
            
            var item : WatchItem!
            if results.count == 0 { // Create a new Watch Item.
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
            if let movieIndex = watchedMovieIds.firstIndex(of: item.id) {
                if movieIndex < watchedMovieIds.count {
                    watchedMovieIds.remove(at: movieIndex)
                }
                print(movieIndex)
            }
            deleteItem(indexNo: sender.tag)
            // delete the selected movie item Watched List Table view, and remove the item from CoreData.
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
//    func removeMovieId(m){
//
//    }
    
}
