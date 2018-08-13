//
//  MenuViewController.swift
//  aivision-ios
//
//  Created by Chris Parsons on 10/08/2018.
//  Copyright © 2018 Chris Parsons. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController{
    
    //MARK: UI Elements
    
    @IBOutlet weak var imageClassificationButton: UIButton!
    @IBOutlet weak var objectDetectionButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disable buttons where we don't have them implemented yet.
        videoButton.isEnabled = false
    
    }
    
}
