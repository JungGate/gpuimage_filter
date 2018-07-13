//
//  ViewController.swift
//  GPUImageFilter
//
//  Created by JungMoon-Mac on 10/07/2018.
//  Copyright © 2018 JungMoon. All rights reserved.
//

import UIKit
import GPUImage

class MainViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    
    let filterDisplayViewController = FilterDisplayViewController(nibName: "FilterDisplayViewController", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterInList = filterOperations[0]
        filterDisplayViewController.filterOperation = filterInList

        addSubFilterDisplayViewController()
    }
    
    func addSubFilterDisplayViewController(){
        addChild(filterDisplayViewController)
        
        let filterView = filterDisplayViewController.view!
        cameraView.addSubview(filterView)
        
        filterView.translatesAutoresizingMaskIntoConstraints = false

        cameraView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[filterView]-0-|",
            options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
            metrics: nil,
            views: ["filterView":filterView]))
        
        cameraView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[filterView]-0-|",
                                                                 options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                 metrics: nil,
                                                                 views: ["filterView":filterView]))

    }
}

