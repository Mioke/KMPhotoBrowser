//
//  KMPhotoBrowserView.swift
//  KMPhotoBrowserDemo
//
//  Created by Klein Mioke on 15/12/14.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import UIKit

private let onePhotoHeight: CGFloat = 175

enum KMPhotoBrowserViewType {
    case AutoComposing(gapWidth: CGFloat)
}

@objc protocol KMPhotoBrowserViewDelegate {
    
    optional func photoBroswerView(view: KMPhotoBrowserView, clickImageAtIndex index: Int) -> Void
}

class KMPhotoBrowserView: UIView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    var gapWidth: CGFloat = 10
    weak var delegate: protocol<KMPhotoBrowserViewDelegate>?
    
    var cacheOptions: SDWebImageOptions = .CacheMemoryOnly
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, imageURLs: [String], type: KMPhotoBrowserViewType) {
        self.init(frame: frame)
        self.setContentWithImageURLs(imageURLs, type: type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContentWithImageURLs(imageURLs: [String], type: KMPhotoBrowserViewType) -> Void {
        
        guard imageURLs.count > 0 else {
            return
        }
        switch type {
        case .AutoComposing(gapWidth: let x):
            
            self.gapWidth = x
            let imageNum = imageURLs.count
            
            // multiple images
            if imageNum > 1 {
                let imageWidth = (frame.width - self.gapWidth * 2) / 3
                
                var xPoint = CGFloat(-(imageWidth + self.gapWidth))
                var yPoint = CGFloat(0)
                
                let numbersInALine: CGFloat = imageNum == 4 ? 2 : 3
                
                var tag: Int = 0
                for urlString in imageURLs {
                    
                    xPoint += imageWidth + self.gapWidth
                    
                    if xPoint >= numbersInALine * (imageWidth + self.gapWidth) {
                        yPoint += imageWidth + self.gapWidth
                        xPoint = 0
                    }
                    
                    let button = UIButton(frame: CGRectMake(xPoint, yPoint, imageWidth, imageWidth))
                    button.tag = tag++
                    button.imageView?.contentMode = .ScaleAspectFill
                    
                    button.addTarget(self, action: "clickImageButton:", forControlEvents: .TouchUpInside)
                    
                    self.addSubview(button)
                    
                    let url: NSURL
                    if urlString.isLocalPath() {
                        url = NSURL(fileURLWithPath: urlString)
                    } else {
                        url = NSURL(string: urlString)!
                    }
                    button.sd_setImageWithURL(url, forState: .Normal, placeholderImage: UIImage(named: "share_photo_placeholder"), options: self.cacheOptions)
                }
                self.height = yPoint + imageWidth
            }
                // only one image will be composing in another way
            else {
                let imageHeight: CGFloat = onePhotoHeight
                
                let button = UIButton(frame: CGRectMake(0, 0, self.frame.size.width, imageHeight))
                button.imageView?.contentMode = .ScaleAspectFill
                button.addTarget(self, action: "clickImageButton:", forControlEvents: .TouchUpInside)
                
                self.addSubview(button)
                
                let url: NSURL
                if imageURLs.first!.isLocalPath() {
                    url = NSURL(fileURLWithPath: imageURLs.first!)
                } else {
                    url = NSURL(string: imageURLs.first!)!
                }

                button.sd_setImageWithURL(
                    url,
                    forState: .Normal,
                    placeholderImage: UIImage(named: "share_cover_placeholder"),
                    options: self.cacheOptions,
                    completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    
                        if image != nil {
                            let ratio = imageHeight / image.size.height
                            let imageWidth = image.size.width * ratio < self.width ? image.size.width * ratio : self.width
                            
                            button.width = imageWidth
                        }
                })
                
                button.clipsToBounds = true
                
                self.height = imageHeight
            }
        }
    }
    
    func setContentWithImages(images: [UIImage], type: KMPhotoBrowserViewType) {
        
        guard images.count > 0 else {
            return
        }
        switch type {
        case .AutoComposing(gapWidth: let x):
            
            self.gapWidth = x
            let imageNum = images.count
            
            // multiple images
            if imageNum > 1 {
                let imageWidth = (frame.width - self.gapWidth * 2) / 3
                
                var xPoint = CGFloat(-(imageWidth + self.gapWidth))
                var yPoint = CGFloat(0)
                
                let numbersInALine: CGFloat = imageNum == 4 ? 2 : 3
                
                var tag: Int = 0
                for image in images {
                    
                    xPoint += imageWidth + self.gapWidth
                    
                    if xPoint >= numbersInALine * (imageWidth + self.gapWidth) {
                        yPoint += imageWidth + self.gapWidth
                        xPoint = 0
                    }
                    
                    let button = UIButton(frame: CGRectMake(xPoint, yPoint, imageWidth, imageWidth))
                    button.tag = tag++
                    button.imageView?.contentMode = .ScaleAspectFill
                    
                    button.addTarget(self, action: "clickImageButton:", forControlEvents: .TouchUpInside)
                    
                    self.addSubview(button)
                    
                    button.setImage(image, forState: UIControlState.Normal)
                }
                self.height = yPoint + imageWidth
            }
                // only one image will be composing in another way
            else {
                let imageHeight: CGFloat = onePhotoHeight
                
                let image = images.first!
                let ratio = imageHeight / image.size.height
                let imageWidth = image.size.width * ratio < self.width ? image.size.width * ratio : self.width
                
                let button = UIButton(frame: CGRectMake(0, 0, imageWidth, imageHeight))
                button.imageView?.contentMode = .ScaleAspectFill
                button.addTarget(self, action: "clickImageButton:", forControlEvents: .TouchUpInside)
                
                self.addSubview(button)
                
                button.setImage(image, forState: .Normal)
                button.clipsToBounds = true
                
                self.height = imageHeight
            }
        }
    }
    
    func calculateSizeWithImagesCount(count: Int, type: KMPhotoBrowserViewType) -> CGRect {
        
        switch type {
        case .AutoComposing(gapWidth: let x):
            
            self.gapWidth = x
            
            // multiple images
            if count > 1 {
                let imageWidth = (frame.width - self.gapWidth * 2) / 3
                let numOfLine = count % 3 == 0 ? count / 3 : count / 3 + 1
                
                self.height = CGFloat(numOfLine) * imageWidth + self.gapWidth * CGFloat(numOfLine - 1)
            }
                // only one image will be composing in another way
            else {
                self.height = onePhotoHeight
            }
        }
        return self.frame
    }
    
    func clickImageButton(button: UIButton) -> Void {
        
        self.delegate?.photoBroswerView?(self, clickImageAtIndex: button.tag)
    }
}
