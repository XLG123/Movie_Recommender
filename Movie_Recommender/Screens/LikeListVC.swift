//
//  LikeListVC.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 04/16/22.
//

import UIKit
import AlamofireImage
import CoreData


class LikeListVC: UIViewController {
    
    @IBOutlet weak var tableV: UITableView!
    var items = [LikeItem]()
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Likes List"
        fetchStoredRecords()
    }
    
    func fetchStoredRecords(){
        let ctx = appDel.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LikeItem")
        fetchRequest.predicate = NSPredicate(format: "isLike = true")
        
        do{
            items = try ctx.fetch(fetchRequest) as! [LikeItem]
            print("Len \(items.count)")
            
            self.tableV.reloadData()
        }catch{
            
        }
    }
}


extension LikeListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            let lbl = UILabel(frame: tableView.frame)
            lbl.text = "No Data"
            lbl.textAlignment = .center
            tableV.backgroundView = lbl
            return items.count
            
        }
        tableV.backgroundView = nil
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185" //w342
        let imgURLString = (img_base_url + poster_size + item.poster_path!)
        let imgURL = URL(string: imgURLString)
        
        
        let imgV = cell!.viewWithTag(1) as! UIImageView
        imgV.af.setImage(withURL: imgURL!)
        
        let lbl = cell!.viewWithTag(2) as! UILabel
        lbl.text = item.title
        
        let watchBtn = cell!.viewWithTag(3) as! UIButton
        watchBtn.tag = indexPath.row
        watchBtn.addTarget(self, action: #selector(moveToWatch(sender:)), for: .touchUpInside)
        
        
        let watchedBtn = cell!.viewWithTag(4) as! UIButton
        watchedBtn.tag = indexPath.row
        watchedBtn.addTarget(self, action: #selector(moveToWatched(sender:)), for: .touchUpInside)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    
    @objc func moveToWatch(sender:UIButton){
        
        let clickedItem = items[sender.tag]
        
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchItem] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchItem")
        //filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        do {
            results = try managedObjectContext.fetch(fetchRequest)  as! [WatchItem]
            
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
            
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }
    
    
    @objc func moveToWatched(sender:UIButton){
        
        let clickedItem = items[sender.tag]
        
        let managedObjectContext = appDel.persistentContainer.viewContext
        var results: [WatchedItem] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchedItem")
        //filtering entities with id
        fetchRequest.predicate = NSPredicate(format: "id == %d",clickedItem.id)
        
        do {
            results = try managedObjectContext.fetch(fetchRequest)  as! [WatchedItem]
            
            var item : WatchedItem!
            if results.count == 0 {
                //if record not already exist then create new & inster in database
                item = WatchedItem(context: appDel.persistentContainer.viewContext)
            }else{
                //if record exist then update in database
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
}
