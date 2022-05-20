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
        self.navigationItem.title = "Likes ♥"
        fetchStoredRecords() // Fetch all data once the view loads.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStoredRecords()
        self.tableV.reloadData()
        
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
    
    // ChangeHere
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
     
        let detailsVC = segue.destination as! MovieDetailsViewController //destination view controller
        let item = sender as! LikeItem
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
        self.performSegue(withIdentifier: "likedListToDetails", sender: movie)
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
