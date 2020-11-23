//
//  HomeViewController.swift
//  FaceRecognitionDemo
//
//  Created by SATABHISHA ROY on 23/09/20.
//  Copyright © 2020 SATABHISHA ROY. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    



    @IBAction func btn_start(_ sender: Any) {
        self.performSegue(withIdentifier: "dashboard", sender: nil)
    }
}
