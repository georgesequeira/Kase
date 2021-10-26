//
//  Mark.swift
//  Kase
//
//  Created by George Sequeira on 2/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//

import UIKit


struct Episode: Codable{
    let podcastName: String
    let episodeName: String
    let albumImageData: Data?
    let episodeUrl: String
    var marks: [Mark]?
}
