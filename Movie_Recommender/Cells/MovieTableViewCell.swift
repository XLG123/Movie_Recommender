//
//  MovieTableViewCell.swift
//  Movie_Recommender
//
//  Created by Xiao Lin Guan on 05/03/22.
//

import UIKit

class MovieTVC: UITableViewCell {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    
    @IBOutlet weak var movieDate: UILabel!
    @IBOutlet weak var movieTagLine: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
