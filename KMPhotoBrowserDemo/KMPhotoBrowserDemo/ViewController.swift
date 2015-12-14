//
//  ViewController.swift
//  KMPhotoBrowserDemo
//
//  Created by Klein Mioke on 15/12/14.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageURLs: [String]!
    var images: [UIImage]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imageURLs = [
            NSBundle.mainBundle().pathForResource("1@2x", ofType: ".jpg")!,
            NSBundle.mainBundle().pathForResource("2@2x", ofType: ".jpg")!,
            NSBundle.mainBundle().pathForResource("3@2x", ofType: ".jpg")!,
            NSBundle.mainBundle().pathForResource("4@2x", ofType: ".jpg")!,
            NSBundle.mainBundle().pathForResource("5@2x", ofType: ".jpg")!,
            NSBundle.mainBundle().pathForResource("6@2x", ofType: ".jpg")!
        ]
        
        let photoView = KMPhotoBrowserView(frame: CGRectMake(15, 100, UIScreen.mainScreen().bounds.size.width - 90, 0), imageURLs: self.imageURLs, type: KMPhotoBrowserViewType.AutoComposing(gapWidth: 5))
        photoView.delegate = self
        self.view.addSubview(photoView)
        
        // or
        
//        self.images = [
//            UIImage(named: "1")!,
//            UIImage(named: "2")!,
//            UIImage(named: "3")!,
//            UIImage(named: "4")!,
//            UIImage(named: "5")!,
//            UIImage(named: "6")!
//        ]
//        photoView.setContentWithImages(self.images, type: KMPhotoBrowserViewType.AutoComposing(gapWidth: 5))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: KMPhotoBrowserViewDelegate {
    
    func photoBroswerView(view: KMPhotoBrowserView, clickImageAtIndex index: Int) {
        
        let vc = KMPhotoBrowserViewController()
        vc.imageURLs = self.imageURLs
        /* or vc.images = self.images */
        
        vc.delegate = self
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

extension ViewController: KMPhotoBrowserDelegate {
    
    func photoBrowserVC(vc: KMPhotoBrowserViewController, deleteImageAtIndex index: Int) {
        
    }
}

