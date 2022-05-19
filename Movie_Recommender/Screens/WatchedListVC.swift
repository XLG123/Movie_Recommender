//
//  WatchedListVC.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 04/26/22.
//

import UIKit
import AlamofireImage
import CoreData

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
            lbl.text = "Add Movies to your Watched List"
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
    
    // Delete a movie from list and remove the item from CoreData.
    func deleteItem(indexNo:Int){
        let ctx = appDel.persistentContainer.viewContext
        ctx.delete(items[indexNo])
        appDel.saveContext()
        fetchStoredRecords()
    }
}
