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
//            print("Len \(items.count)") // print out the list size.
            for item in items {
                if !likedMovieIds.contains(item.id) {
                    likedMovieIds.append(item.id)
                }
            }
//            print(likedMovieIds)
            
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
            lbl.text = "Add Movies to your Likes List"
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
        let img_base_url = "https://image.tmdb.org/t/p/"
        let poster_size = "w185" //w342
        let poster_path = item.poster_path ?? ""
        let imgURLString = (img_base_url + poster_size + poster_path)
        let imgURL = URL(string: imgURLString)
        
        cell.imgV.af.setImage(withURL: imgURL!, placeholderImage: UIImage(named: "no_image_available"))
        cell.titleLbl.text = item.title
        tableView.separatorColor = UIColor.gray
        tableView.tableHeaderView = UIView() // remove separator at the top of the list
        cell.separatorInset = UIEdgeInsets.init(top: 0.0, left: 10.0, bottom: 0, right: 10.0)
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
    
    // Remove movie from Likes List.
    func deleteItem(indexNo:Int){
        if (indexNo < likedMovieIds.count) {
            likedMovieIds.remove(at: indexNo)
        }
        let ctx = appDel.persistentContainer.viewContext
        ctx.delete(items[indexNo])
        appDel.saveContext()
        fetchStoredRecords()
    }
}
