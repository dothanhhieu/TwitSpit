//
//  ContentTableViewCell.swift
//  TwitSplit
//
//  Created by Hieu Do on 10/2/17.
//  Copyright © 2017 Hieu Do. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    
        @IBOutlet weak var imgAvatar: UIImageView!
        @IBOutlet weak var viewContent: UIView!
        @IBOutlet weak var viewBackground: UIView!
        @IBOutlet weak var lblText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height/2
        imgAvatar.clipsToBounds = true
        viewBackground.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
