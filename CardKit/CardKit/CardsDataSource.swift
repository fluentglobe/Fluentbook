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

class CardDescription {
    var title:String = "Some Card"
    var progress:Float = 0.5
    var color = randomUIColor()
    
    init() {
    }
    
    init(_ _name:String, _ _progress:Float) {
        self.title = _name
        self.progress = _progress
    }
}

func cardDefs() -> NSMutableArray {
    let cards:NSArray = [
        CardDescription("Day of the week", 0.1),
        CardDescription("Supermarket Counter",0.2),
        CardDescription("Numbers Bingo",0.3),
        CardDescription("Weekend Visit Story",0.4),
        CardDescription("Complete the Dialog",0.5),
        CardDescription("Speak the Pictures",0.6),
        CardDescription("Day of the week", 0.1),
        CardDescription("Supermarket Counter",0.2),
        CardDescription("Numbers Bingo",0.3),
        CardDescription("Weekend Visit Story",0.4),
        CardDescription("Complete the Dialog",0.5),
        CardDescription("Speak the Pictures",0.6),
        CardDescription("Card #6",0.8)

    ]
    return NSMutableArray(array: cards)
}


class CardsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @lazy var cards = cardDefs()
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCell", forIndexPath: indexPath) as UICollectionViewCell
        if let cardCell = cell as? CardViewCell {
            if let card = self.cards[indexPath.item] as? CardDescription {
                cardCell.title = card.title + " (\(indexPath.item))"
                cardCell.progress = card.progress
                cardCell.color = UIColor.whiteColor()
            }
        }
        
        return cell
    }
    
    /*
    override func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
    println("Select item \(indexPath.row) section \(indexPath.section)")
    }
    */
    
}
