# Scanning
< how to use
let twoDimension = TwoDimensionViewController()
twoDimension.createBackBtn()
twoDimension.suncess { (twoDimensionViewController, typeNum) in
            
    //code
}
        
twoDimension.fail { (twoDimensionViewController) in
            
    //code
}
        
twoDimension.cancel { (twoDimensionViewController) in
            
    //code
}
        
let nav = UINavigationController(rootViewController: twoDimension)
self.presentViewController(nav, animated: true, completion: nil)
