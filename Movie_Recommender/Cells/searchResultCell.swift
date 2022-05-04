//
//  searchResultCell.swift
//  Movie_Recommender
//
//  Created by Fnu Tsering on 3/22/22.
//

import UIKit

class searchResultCell: UITableViewCell {


    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
