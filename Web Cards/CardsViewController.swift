//
//  CardsViewController.swift
//  webcards
//
//  Created by Henrik Vendelbo on 21/06/2014.
//  Copyright (c) 2014 Right Here Inc. All rights reserved.
//

import UIKit

class CardsViewController: UICollectionViewController{

    /*
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Custom initialization
        //self.collectionView.registerClass(CardViewCell.self, forCellWithReuseIdentifier: "CELL")
    }
    */

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //TODO low memory notifies active webviews to cut down activity
    }
    
    // for now, consider matching with background image
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //TODO use a separate URL connection (AFNetworking ?)
    // connection:didRecieveAuthenticationChallenge
    // store credentials with NSURLCredentialPersistenceForSession
    // this applies to the UIWebView's
    
    // consider if credentials are unavailable during background fetch
    
}


