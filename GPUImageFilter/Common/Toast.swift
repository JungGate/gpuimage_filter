//
//  Toast.swift
//  FilterShowcase
//
//  Created by JungMoon-Mac on 2018. 3. 30..
//  Copyright © 2018년 Sunset Lake Software. All rights reserved.
//

import UIKit

class Toast: NSObject {
    static func showToast(title:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let view = appDelegate.window?.rootViewController?.view
        view?.makeToast(title)
    }
}

