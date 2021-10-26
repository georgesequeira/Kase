//
//  MarkTableViewCell.swift
//  Kase
//
//  Created by George Sequeira on 2/18/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit
import SwipeCellKit


class MarkTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var timeMark: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var notePreviewLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
