//
//  DataMan.swift
//  Students
//
//  Created by Jay Patel on 2/3/20.
//  Copyright © 2020 Lake. All rights reserved.
//

import UIKit

class DataMan: NSObject
{
    
    var dictionary: NSDictionary? //local cache
    
    //singleton - make it once and use it throughout the app
       static var dataSharedInstance = DataMan()
       static var sharedInstance: DataMan
       {
           return self.dataSharedInstance
       }

}
