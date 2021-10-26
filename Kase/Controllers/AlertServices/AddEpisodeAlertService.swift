//
//  AlertService.swift
//  Kase
//
//  Created by George Sequeira on 2/10/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import UIKit

class AddEpisodeAlertService {
    func alert(addUrl: @escaping (String, Int, Int, Int, String) -> ()) -> AlertViewController {
        let storyboard = UIStoryboard(name: "AddLikeStoryboard", bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: "addLikeVC") as! AlertViewController
        alertVC.doneSaving = addUrl
        return alertVC
    }
}
