//
//  ClipTableViewCell.swift
//  Kase
//
//  Created by George Sequeira on 2/6/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit
import SwipeCellKit

class ClipTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var podcastEpisodeName: UILabel!
    @IBOutlet weak var marksLabel: UILabel!
    @IBOutlet weak var albumView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
