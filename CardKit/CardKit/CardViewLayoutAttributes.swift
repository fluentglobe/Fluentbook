//
//  CardViewLayoutAttributes.swift
//  Web Cards
//
//  Created by Henrik Vendelbo on 25/06/2014.
//  Copyright (c) 2014 Right Here Inc. All rights reserved.
//

import UIKit

class CardViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var foreground = false
    
    override func copyWithZone(zone: NSZone) -> AnyObject! {
        var copy = super.copyWithZone(zone) as CardViewLayoutAttributes
        copy.foreground = self.foreground
        
        return copy
    }
}
