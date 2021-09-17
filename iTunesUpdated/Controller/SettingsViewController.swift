//
//  SettingsViewController.swift
//  iTunesUpdated
//
//  Created by Jay Patel on 12/5/19.
//  Copyright © 2019 Lake. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var SettingsLabel: UILabel!
    @IBOutlet weak var explicitLabel: UILabel!
    @IBOutlet weak var explicitSwitch: UISwitch!
    
    @IBAction func switchAction(_ sender: UISwitch)
    {
    
    
   
    
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
        if(explicitSwitch.isOn == true)
        {
          
            
                appDelegate.hasExplicit = true
               
              
        }
        else
        {
 
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate
            {
                appDelegate.hasExplicit = false
               
                
            }
            
        }
        }
        
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
