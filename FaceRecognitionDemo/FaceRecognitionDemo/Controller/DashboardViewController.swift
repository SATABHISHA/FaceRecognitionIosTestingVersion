//
//  DashboardViewController.swift
//  FaceRecognitionDemo
//
//  Created by SATABHISHA ROY on 23/09/20.
//  Copyright © 2020 SATABHISHA ROY. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btn_selfie(_ sender: Any) {
        self.performSegue(withIdentifier: "selfie", sender: nil)
    }
    

    @IBAction func btn_realtime(_ sender: Any) {
        self.performSegue(withIdentifier: "realtimedetector", sender: nil)
    }
    
    @IBAction func btn_enroll(_ sender: Any) {
        self.performSegue(withIdentifier: "enroll", sender: nil)
    }
    
}
