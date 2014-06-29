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

let HTML_BEGIN = "<html><body>"
let HTML_END = "</body></html>"
let HTML_ONE_PLACE = "<p>Fluentbook keeps your language materials: exercises, conversations, and chapters in one place.</p>"
let HTML_SCAN_BARCODE = "<p>To get materials scan a barcode or ask your teacher to assign material to you.</p>"

class CardDescription {
    var title:String = "Some Card"
    var progress:Float = 0.5
    var color = randomUIColor()
    var html:String? = HTML_BEGIN + HTML_ONE_PLACE + HTML_SCAN_BARCODE + HTML_END
    var url:NSURL? = nil
    
    init() {
    }

    init(_ _name:String, _ _progress:Float) {
        self.title = _name
        self.progress = _progress
    }
    
    init(_ _name:String, _ _progress:Float, url:String) {
        self.title = _name
        self.progress = _progress
        self.url = NSURL(string:url)
        self.html = nil
    }
}

func cardDefs() -> NSMutableArray {
    let cards:NSArray = [
        CardDescription("Introduction", 0, url: "http://fluentglobe.com/zurich/book-intro.html"),
        CardDescription("Day of the week", 0.1, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Supermarket Counter",0.2, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Numbers Bingo",0.3, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Weekend Visit Story",0.4, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Complete the Dialog",0.5, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Speak the Pictures",0.6, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Day of the week", 0.1, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Supermarket Counter",0.2, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Numbers Bingo",0.3, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Weekend Visit Story",0.4, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Complete the Dialog",0.5, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Speak the Pictures",0.6, url: "http://fluentglobe.com/book/exercise.html"),
        CardDescription("Card #6",0.8, url: "http://fluentglobe.com/book/exercise.html")

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
                cardCell.setHTML(card)
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
