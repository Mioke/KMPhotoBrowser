//
//  KMPhotoBrowserViewController.swift
//  KMPhotoBrowserDemo
//
//  Created by Klein Mioke on 15/12/14.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import UIKit

@objc protocol KMPhotoBrowserDelegate {
    optional func photoBrowserVC(vc: KMPhotoBrowserViewController, deleteImageAtIndex index: Int) -> Void
}

class KMPhotoBrowserViewController: UIViewController {

    weak var delegate: protocol<KMPhotoBrowserDelegate>?
    var cacheOptions = SDWebImageOptions.CacheMemoryOnly
    
    var scrollView: UIScrollView!
    var images: Array<UIImage>?
    
    var imageURLs: [String]?
    var clickForBack: Bool = false
    
    var currentIndex: Int = 0 {
        didSet {
            if self.titleLabel != nil {
                
                if self.images != nil {
                    self.titleLabel.text = "\(self.currentIndex + 1)/\(self.images!.count)"
                } else {
                    self.titleLabel.text = "\(self.currentIndex + 1)/\(self.imageURLs!.count)"
                }
            }
        }
    }
    
    var topBar: UIView!
    var titleLabel: UILabel!
    
    var bottomBar: UIView!
    
    var isModified: Bool = false
    
    var callBack: ((images: [UIImage], isModified: Bool)->())?
    
    var rightNavigationItemOption: PBVCRightNaviItemOption?
    var rightNavigationItemOption_oc: NSDictionary?
    
    struct PBVCRightNaviItemOption {
        
        var icon: UIImage
        var text: NSAttributedString
        var action: UIViewController -> Void
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        assert(self.images != nil || self.imageURLs != nil, "PhotoBrowserVC必须传入UIImage数组")
        
        self.edgesForExtendedLayout = .All
        
        self.scrollView = {
            let view = UIScrollView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
            view.backgroundColor = UIColor.blackColor()
            view.pagingEnabled = true
            
            view.delegate = self
            
            self.view.addSubview(view)
            
//            let gesture = UITapGestureRecognizer(target: self, action: "handleClickAction")
//            view.addGestureRecognizer(gesture)
            return view
        }()
        
        self.topBar = {
            let bar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
            bar.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3)
            
            let backButton = UIButton(frame: CGRectMake(0, 20, 60, 44))
            backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
            
            backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
            backButton.setImage(UIImage(named: "back_p"), forState: UIControlState.Highlighted)
            
            backButton.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
            
            bar.addSubview(backButton)
            
            let deleteButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - 60, 20, 60, 44))
            
            if let option = self.rightNavigationItemOption {
                deleteButton.setImage(option.icon, forState: UIControlState.Normal)
                deleteButton.setAttributedTitle(option.text, forState: UIControlState.Normal)
                
            } else {
                if let option = self.rightNavigationItemOption_oc {
                    deleteButton.setImage(option["icon"] as? UIImage, forState: UIControlState.Normal)
                    deleteButton.setAttributedTitle(option["text"] as? NSAttributedString, forState: UIControlState.Normal)
                } else {
//                    deleteButton.setTitle("删除", forState: UIControlState.Normal)
//                    deleteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//                    deleteButton.titleLabel?.font = UIFont.systemFontOfSize(14)
                    
                    deleteButton.setImage(UIImage(named: "del"), forState: UIControlState.Normal)
                    deleteButton.setImage(UIImage(named: "del_p"), forState: UIControlState.Highlighted)
                    deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
                }
            }
            deleteButton.addTarget(self, action: "deletePicture", forControlEvents: UIControlEvents.TouchUpInside)
            
            bar.addSubview(deleteButton)
            
            self.view.addSubview(bar)
            
            self.titleLabel = {
                
                let label = UILabel(frame: CGRectMake((bar.width - 200) / 2, 20, 200, 44))
                label.textColor = UIColor.whiteColor()
                label.textAlignment = .Center
                label.font = UIFont.systemFontOfSize(16)
                
                bar.addSubview(label)
                
                return label
            }()
            
            return bar
        }()
        self.currentIndex = Int(self.currentIndex)
        
        self.loadContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.clickForBack {
            let tap = UITapGestureRecognizer(target: self, action: "back")
            self.scrollView?.addGestureRecognizer(tap)
        }
    }
    
    func loadContent() {
        
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        var xPoint: CGFloat = 0
        var tag = 100
        
        if self.images != nil {
            
            for image in self.images! {
                let view = UIImageView(image: image)
                view.backgroundColor = UIColor.clearColor()
                view.contentMode = .ScaleAspectFit
                view.tag = tag
                
                view.frame = CGRectMake(0, 0, self.scrollView.width, self.scrollView.width * image.size.height / image.size.width)
                
                let container = UIScrollView(frame: CGRectMake(xPoint, 0, self.scrollView.width, self.scrollView.height))
                container.backgroundColor = UIColor.clearColor()
                
                container.clipsToBounds = true
                container.maximumZoomScale = 2.0
                //            container.showsHorizontalScrollIndicator = false
                
                container.delegate = self
                container.tag = 100 + tag++
                container.addSubview(view)
                
                view.center = CGRectGetCenter(container.bounds)
                
                self.scrollView.addSubview(container)
                
                xPoint += self.view.width
            }
        }
        else if self.imageURLs != nil {
            
            for urlString in self.imageURLs! {
                let view = UIImageView()
                
                weak var weakView = view
                
                var url: NSURL
                if urlString.isLocalPath() {
                    url = NSURL(fileURLWithPath: urlString)
                } else {
                    url = NSURL(string: urlString)!
                }
                
                view.sd_setImageWithURL(url, placeholderImage: UIImage(named: "share_photo_placeholder"), options: self.cacheOptions, completed: { (img: UIImage!, error: NSError!, cacheType: SDImageCacheType, url: NSURL!) -> Void in
                    
                    if img != nil {
                        weakView?.frame = CGRectMake(0, 0, self.scrollView.width, self.scrollView.width * img.size.height / img.size.width)
                        weakView?.center = CGRectGetCenter(self.view.bounds)
                    }
                })
                view.backgroundColor = UIColor.clearColor()
                view.contentMode = .ScaleAspectFit
                view.tag = tag
                
                let container = UIScrollView(frame: CGRectMake(xPoint, 0, self.scrollView.width, self.scrollView.height))
                container.backgroundColor = UIColor.clearColor()
                
                container.clipsToBounds = true
                container.maximumZoomScale = 2.0
                //            container.showsHorizontalScrollIndicator = false
                
                container.delegate = self
                container.tag = 100 + tag++
                container.addSubview(view)
                
                view.center = CGRectGetCenter(container.bounds)
                
                self.scrollView.addSubview(container)
                
                xPoint += self.view.width
            }
        }
        self.scrollView.contentSize = CGSizeMake(xPoint, 0)
        self.scrollView.setContentOffset(CGPointMake(self.view.width * CGFloat(self.currentIndex), 0), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleClickAction() -> Void {
        
    }
    
    func deletePicture() {
        
        guard self.images != nil else {
            return
        }
        if let option = self.rightNavigationItemOption {
            option.action(self)
            
        } else {
            if let option = self.rightNavigationItemOption_oc {
                
                if let action = option["action"] as? UIViewController -> Void {
                    action(self)
                }
            } else {
                if self.images!.count != 0 {
                    
                    let sheet = UIActionSheet(title: "要删除这张照片吗?", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "删除")
                    sheet.actionSheetStyle = .BlackTranslucent
                    sheet.showInView(self.view)
                }
            }
        }
    }
    
    func back() {
        
        if self.clickForBack {
            self.modalTransitionStyle = .CrossDissolve
        }
        self.callBack?(images: self.images!, isModified: self.isModified)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension KMPhotoBrowserViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        if scrollView != self.scrollView {
            return scrollView.viewWithTag(100 + self.currentIndex)
        }
        return nil
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        if let view = scrollView.viewWithTag(100 + self.currentIndex) {
            
            var offsetX = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5
            offsetX = offsetX > 0 ? offsetX : 0
            
            var offsetY = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5
            offsetY = offsetY > 0 ? offsetY : 0
            
            view.center = CGPointMake(offsetX + scrollView.contentSize.width * 0.5, offsetY + scrollView.contentSize.height * 0.5)
        }
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {

    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == self.scrollView {
            let targetX = targetContentOffset.memory.x
            let targetPage = Int(ceil(targetX / self.view.width))
            
            if targetPage != self.currentIndex {
                if let container = self.scrollView.viewWithTag(200 + self.currentIndex) as? UIScrollView {
                    container.setZoomScale(1, animated: true)
                }
            }
            self.currentIndex = targetPage
        }
    }
}

extension KMPhotoBrowserViewController: UIActionSheetDelegate {
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == actionSheet.destructiveButtonIndex {
            self.images!.removeAtIndex(self.currentIndex)
            self.isModified = true
            
            self.delegate?.photoBrowserVC?(self, deleteImageAtIndex: self.currentIndex)
            
            if self.images!.count <= self.currentIndex {
                self.currentIndex = self.images!.count - 1
            } else {
                self.currentIndex = Int(self.currentIndex)
            }
            self.loadContent()
        }
    }
}
