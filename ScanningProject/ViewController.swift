//
//  ViewController.swift
//  ScanningProject
//
//  Created by LMC LMC on 2017/3/28.
//  Copyright © 2017年 LMC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnClick(sender: UIButton) {
        
        let twoDimension = TwoDimensionViewController()
        twoDimension.createBackBtn()
        twoDimension.suncess { (twoDimensionViewController, typeNum) in
            
            self.setupAlertView("success", content: typeNum as String)
        }
        
        twoDimension.fail { (twoDimensionViewController) in
            
            self.setupAlertView("fail", content: "")
        }
        
        twoDimension.cancel { (twoDimensionViewController) in
            
            self.setupAlertView("cancel", content: "")
        }
        
        let nav = UINavigationController(rootViewController: twoDimension)
        self.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    func setupAlertView(title: String?, content: String?) {
        let alertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "close", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let time: NSTimeInterval = 0.1
        let delay = dispatch_time(DISPATCH_TIME_NOW,
                                  Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
        
    }


}

