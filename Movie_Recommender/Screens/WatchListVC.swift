//
//  WatchListVC.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 04/19/22.
//

import UIKit
import AlamofireImage
import CoreData

class WatchListVC: UIViewController {
    
    @IBOutlet weak var tableV: UITableView!
    var items = [WatchItem]() // An array of watch movies.
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Want to Watch"
        fetchStoredRecords() // Fetch all data once the view loads.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStoredRecords()
        self.tableV.reloadData()
    }
    
    func fetchStoredRecords(){
        let ctx = appDel.persistentContainer.viewContext
        do{
            items = try ctx.fetch(WatchItem.fetchRequest())
            print("Len \(items.count)") // print out the list size
            
            self.tableV.reloadData()
        }catch{
            print("data might be corrupted, error: \(error)")
        }
    }
    
    // ChangeHere
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
     
        let detailsVC = segue.destination as! MovieDetailsViewController //destination view controller
        let item = sender as! WatchItem
        var movieSelected = [String: Any]()
        movieSelected["adult"] = item.adult
        movieSelected["backdrop_path"] = item.backdrop_path
        movieSelected["id"] = Int(item.id)
        movieSelected["media_type"] = item.media_type
        movieSelected["original_language"] = item.original_language
        movieSelected["original_title"] = item.original_title
        movieSelected["overview"] = item.overview
        movieSelected["popularity"] = item.popularity
        movieSelected["poster_path"] = item.poster_path
        movieSelected["release_date"] = item.release_date
        movieSelected["title"] = item.title
        movieSelected["video"] = item.video
        movieSelected["vote_average"] = item.vote_average
        movieSelected["vote_count"] = item.vote_count
        
        detailsVC.movieSelected = movieSelected as [String:Any]?
        
    }
}

// A table view that contains a list of watch movies.
extension WatchListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if list size is 0, show a label with message "No Data", then return 0.
        if items.count == 0 {
            let lbl = UILabel(frame: tableView.frame)
            lbl.text = "Add Movies to your Watch List"
            lbl.textColor = UIColor.white
            lbl.font = lbl.font.withSize(22)
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
        
        //Add release date and tagline here
        
        //set release date
        if (item.release_date) != nil{
            cell.movieDate.text = item.release_date
        } else {
            cell.movieDate.text = ""
        }
        
        //set overview
        if (item.overview) != nil{
            cell.movieTagLine.text = item.overview
        } else {
            cell.movieTagLine.text = ""
        }
        
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185" //w342
        let poster_path = item.poster_path ?? ""
        let imgURLString = (img_base_url + poster_size + poster_path)
        let imgURL = URL(string: imgURLString)
        
        cell.imgV.af.setImage(withURL: imgURL!, placeholderImage: UIImage(named: "no_image_available"))
        cell.titleLbl.text = item.title
        cell.secondBtn.tag = indexPath.row
        cell.secondBtn.layer.cornerRadius = 4.0
        cell.secondBtn.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        cell.secondBtn.addTarget(self, action: #selector(moveToWatched(sender:)), for: .touchUpInside)
        //tableView.separatorColor = UIColor.gray
        //tableView.tableHeaderView = UIView() // remove separator at the top of the list
        //cell.separatorInset = UIEdgeInsets.init(top: 0.0, left: 10.0, bottom: 0, right: 10.0)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            print("delete")
            deleteItem(indexNo: indexPath.row)
        }
    }
    
    // ChangeHere
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = items[indexPath.row]
        self.performSegue(withIdentifier: "watchlistToDetails", sender: movie)
    }
    
    // Delete a movie from list and remove the item from CoreData.
    func deleteItem(indexNo:Int){
        let ctx = appDel.persistentContainer.viewContext
        ctx.delete(items[indexNo])
        appDel.saveContext()
        fetchStoredRecords()
    }
    
    // Move the movie to Watched List.
    @objc func moveToWatched(sender:UIButton){
        
//        get current time
        let currentTime = Date();
        let df = DateFormatter();
        df.dateFormat = "yyyy-MM-dd";
        let dateString = df.string(from: currentTime);
//        print(dateString)
        
        let clickedItem = items[sender.tag]
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchedItem] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        
        // filtering entities
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        let release_date = clickedItem.release_date!
        
        if release_date <= dateString || release_date == ""{
            do {
                results = try managedObjectContext.fetch(fetchRequest) as! [WatchedItem]
                
                var item : WatchedItem!
                if results.count == 0 {
                    item = WatchedItem(context:managedObjectContext)
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
                deleteFromWatch(idStr:NSNumber(value: item.id).intValue) // remove the selected movie item from Watch List
            }
            catch {
                print("error executing fetch request: \(error)")
            }
        } else if release_date > dateString {
            let watchedNotifyFailure = UIAlertController (title: "Movie is not released yet.", message: nil, preferredStyle: UIAlertController.Style.alert)
            let cancelwatchedNotify = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
                   watchedNotifyFailure.addAction(cancelwatchedNotify)
            self.present(watchedNotifyFailure, animated: true, completion: nil)
        }
    }
    
    // Remove movie from Watch List.
    func deleteFromWatch(idStr:Int){
        let ctx = appDel.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        
        // filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",idStr)
        do {
            let results: [WatchItem] = try ctx.fetch(fetchRequest) as! [WatchItem]
            if results.count > 0 {
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
}
