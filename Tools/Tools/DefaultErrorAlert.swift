//
//  DefaultErrorAlert.swift
//  Tools
//
//  Created by John Bobington on 25/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

public struct DefaultErrorAlert: pDefaultAlert {

    public static func makeAndPresent(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
