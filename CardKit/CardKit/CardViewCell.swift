//
//  CardViewCell.swift
//  webcards
//
//  Created by Henrik Vendelbo on 21/06/2014.
//  Copyright (c) 2014 Right Here Inc. All rights reserved.
//

import UIKit
import QuartzCore

class CardViewCell: UICollectionViewCell {
    
    var _title = ""
    var title: String {
        get { return _title }
        set {
            _title = newValue
            if self.nameLabel {
                self.nameLabel.text = newValue
            }
        }
    }
    var color = UIColor.whiteColor()
    
    @IBOutlet var webView: UIWebView = nil
    @IBOutlet var roundedView : UIView = nil
    @IBOutlet var snapshotImageView: UIImageView = nil
    @IBOutlet var nameLabel : UILabel = nil
    
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    init(coder aDecoder:NSCoder!) {
        super.init(coder: aDecoder)
        
        self.backgroundView = UIView(frame: CGRectMake(0,0,100,100))
        //TODO rect full size constraints
        self.selectedBackgroundView = UIView(frame: CGRectMake(0,0,100,100))
        //TODO rect full size constraints
        
        self.backgroundView.backgroundColor = UIColor.clearColor() //self.color
        self.backgroundView.layer.cornerRadius = 7.0
//                self.backgroundView.layer.borderWidth = 1.0
//                self.backgroundView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.selectedBackgroundView.backgroundColor = UIColor.clearColor() //self.color
        self.selectedBackgroundView.layer.cornerRadius = 7.0
        //        self.selectedBackgroundView.layer.borderWidth = 1.0
        //        self.selectedBackgroundView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.backgroundView.clipsToBounds = false
        self.backgroundView.layer.shadowColor = UIColor.grayColor().CGColor
        self.backgroundView.layer.shadowOpacity = Float(0.7)
        self.backgroundView.layer.shadowRadius = Float(4.0)
        self.backgroundView.layer.shadowOffset = CGSizeMake(Float(0.0), Float(-10.0))
        self.backgroundView.layer.shadowPath = UIBezierPath(rect: self.backgroundView.bounds).CGPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
        
        self.nameLabel.text = self.title
        
        self.webView.layer.cornerRadius = 7.0
        self.webView.clipsToBounds = true
        self.snapshotImageView.layer.cornerRadius = 7.0
        self.snapshotImageView.clipsToBounds = true
        
        // for debugging
//        self.webView.layer.borderWidth = 1.0
//        self.webView.layer.borderColor = UIColor.blackColor().CGColor
        
        self.takeSnapshot()
    }
    
    func takeSnapshot() {
        UIGraphicsBeginImageContextWithOptions(self.snapshotImageView.frame.size, true, 0.0) //TODO adjust it perhaps ?
        self.webView.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.snapshotImageView.image = image
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        
        super.applyLayoutAttributes(layoutAttributes)
        
        let cardAttributes = layoutAttributes as CardViewLayoutAttributes
        
        // update the background size to full height
        var bgFrame = self.backgroundView.frame, bgBounds = self.backgroundView.bounds
        bgFrame.size.height = layoutAttributes.size.height
        bgBounds.size.height = layoutAttributes.size.height
        self.backgroundView.frame = bgFrame
        self.selectedBackgroundView.frame = bgFrame
//        self.backgroundView.bounds = bgBounds
//        self.selectedBackgroundView.bounds = bgBounds
        
        //TODO skip if height/width unchanged
        self.backgroundView.layer.shadowPath = UIBezierPath(rect: self.backgroundView.bounds).CGPath
        self.selectedBackgroundView.layer.shadowPath = UIBezierPath(rect: self.selectedBackgroundView.bounds).CGPath
        
        // showing webview or the snapshot
        self.webView.hidden = !cardAttributes.foreground
        self.snapshotImageView.hidden = cardAttributes.foreground
        //TODO other snapshot bits
    }
    
    /*
    func setImage(image:UIImage) {
    //        self.imageView.setImage(image)
    }
    
    func setLabel(text: String) {
    self.nameLabel.text = text
    }
    */
//    func setTitle(title: String) {
//        self.title = title
//        if self.nameLabel {
//            self.nameLabel.text = title
//        }
//    }
    
    func setColor(color: UIColor) {
        self.color = color
        //TODO update backgroundView and selectedBackgroundView
    }
    
    /* TODO
    func setSelected(selected: Bool) {
    
    }
    */
}