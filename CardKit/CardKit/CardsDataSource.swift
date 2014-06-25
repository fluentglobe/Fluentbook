//
//  CardsDataSource.swift
//  webcards
//
//  Created by Henrik Vendelbo on 21/06/2014.
//  Copyright (c) 2014 Right Here Inc. All rights reserved.
//

import UIKit

func randomUIColor() -> UIColor {
    
    func randChannel() -> CGFloat {
        let r = arc4random_uniform(255)
        return CGFloat(r)
    }
    
    return UIColor(red: randChannel(), green: randChannel(), blue: randChannel(), alpha:1.0)
}

func cardDefs() -> NSMutableArray {
    let cards:NSArray = [
        ["name":"Card #0", "color": randomUIColor()],
        ["name":"Card #1", "color": randomUIColor()],
        ["name":"Card #2", "color": randomUIColor()],
        ["name":"Card #3", "color": randomUIColor()],
        ["name":"Card #4", "color": randomUIColor()],
        ["name":"Card #5", "color": randomUIColor()],
        ["name":"Card #6", "color": randomUIColor()],
        ["name":"Card #7", "color": randomUIColor()],
        ["name":"Card #8", "color": randomUIColor()],
        ["name":"Card #9", "color": randomUIColor()]
    ]
    return NSMutableArray(object: cards)
}


class CardsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @lazy var cards = cardDefs()
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCell", forIndexPath: indexPath) as UICollectionViewCell
        if let cardCell = cell as? CardViewCell {
            let title = "Card #" + "\(indexPath.item)"
            cardCell.title = title
            cardCell.color = UIColor.whiteColor()
        }
        
        return cell
    }
    
    /*
    override func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
    println("Select item \(indexPath.row) section \(indexPath.section)")
    }
    */
    
}
