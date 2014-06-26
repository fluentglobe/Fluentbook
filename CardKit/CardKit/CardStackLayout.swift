//
//  CardStackLayout.swift
//  Web Cards
//
//  Created by Henrik Vendelbo on 24/06/2014.
//  Copyright (c) 2014 Right Here Inc. All rights reserved.
//

import UIKit

class CardStackLayout: UICollectionViewLayout {
   
    var exposedItem:Int? = nil
    var cellCount:Int = 0
    var reveal:CGFloat = 0.0
    var center = CGPoint(x: 160, y: 300)
    var exposedSize = CGSize(width: 320, height: 480)
    var exposedHeight = CGFloat(0)
    
    var bottomStackGap = 20.0,
        bottomStackHeight = 50.0
    var layoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
    var bounceFactor = 0.2
    var minReveal:CGFloat = 35.0
    
    //TODO support multi sections: multiple stacks
    
    var attributes = UICollectionViewLayoutAttributes[]()
    
    override func prepareLayout() {
        super.prepareLayout()
        
        // no layout without at least one section
        let numberOfSections = self.collectionView.numberOfSections()
        if numberOfSections == 0 { return }
        
        // exposed/screen center/size
        let viewSize = self.collectionView.frame.size
        self.center = CGPointMake(viewSize.width / 2, viewSize.height / 2)
        self.exposedSize = CGSize(
            width: viewSize.width - self.layoutMargin.left - self.layoutMargin.right,
            height: viewSize.height
                - CGFloat(self.bottomStackGap) - CGFloat(self.bottomStackHeight)
                - self.layoutMargin.top - self.layoutMargin.bottom)
        
        // cells
        self.cellCount = self.collectionView.numberOfItemsInSection(0)
        let perCell:CGFloat = viewSize.height / CGFloat(self.cellCount)
        self.reveal = max(self.minReveal, perCell)
        self.reveal = self.minReveal // testing....
        
        self.exposedHeight = self.exposedSize.height + self.reveal * CGFloat(self.cellCount - 1)

        
        if let cardView = self.collectionView as? CardView {
            self.bounceFactor = cardView.bounceFactor
            //TODO tweak layoutMargin minReveal
        }
        
        // pre-calc attributes
        // placing from the bottom up having the topmost (last in stack) be visually on top
        if self.cellCount != self.attributes.count {
            var forAll = UICollectionViewLayoutAttributes[]()
            for index in 0 .. self.cellCount {
                var path = NSIndexPath(forItem: index, inSection: 0)
                
                let attributes = CardViewLayoutAttributes(forCellWithIndexPath: path)
                attributes.foreground = (self.exposedItem == path.item)
                
                // card has full height whether overlapped or not
                let centerY = self.exposedHeight - CGFloat(Float(path.item) + 0.5) * self.reveal
                attributes.center = CGPointMake(self.center.x, centerY - self.exposedSize.height/2 + self.reveal/2)
                attributes.size = CGSize(width: self.exposedSize.width, height: self.exposedSize.height)
//                attributes.zIndex = index // last card top of pile
                
                forAll.append(attributes)
                
            }
            self.attributes = forAll
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        // switch exposed to spread
        if self.exposedItem == nil {
            let total = self.exposedHeight//CGFloat(self.cellCount) * self.reveal
            return CGSize(
                width: self.exposedSize.width + self.layoutMargin.left + self.layoutMargin.right,
                height: total + self.layoutMargin.top + self.layoutMargin.bottom)
        } else {
            return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        }
        
    }
        
    override func layoutAttributesForElementsInRect(rect: CGRect) -> AnyObject[] {
        
        let attrsInRect = NSMutableArray()
        for attributes in self.attributes {
            if CGRectIntersectsRect(rect, attributes.frame) {
                attrsInRect.addObject(attributes)
            }
        }
        return attrsInRect
    }
    
    override func layoutAttributesForItemAtIndexPath(path:NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if path.section > 1 {
            return nil  //TODO multisection support
        }
        if path.item >= self.cellCount {
            return nil
        }
        return self.attributes[path.item]
    }
    
    //TODO decorator view support:
    // layoutAttributesForDecorationViewWithReuseIdentifier(indexPath)
    
    //TODO supplementary view support
    // layoutAttributesForSupplementaryViewOfKind(indexPath)
}
