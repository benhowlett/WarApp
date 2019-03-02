//
//  InfoViewController.swift
//  WarApp
//
//  Created by Benjamin Howlett on 2019-03-01.
//  Copyright © 2019 Benjamin Howlett. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBAction func benHowlettTapped(_ sender: Any) {
        if let url = URL(string: "https://github.com/benhowlett/WarApp") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func gitHubTapped(_ sender: Any) {
        if let url = URL(string: "https://github.com/benhowlett/WarApp") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}
