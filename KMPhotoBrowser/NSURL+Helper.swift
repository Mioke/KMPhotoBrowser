//
//  NSURL+Helper.swift
//  KMPhotoBrowserDemo
//
//  Created by Klein Mioke on 15/12/14.
//  Copyright © 2015年 KleinMioke. All rights reserved.
//

import Foundation

extension NSURL {
    
    func isLocalPath() -> Bool {
        return self.absoluteString.rangeOfString("http") == nil
    }
}

extension String {
    
    func isLocalPath() -> Bool {
        return self.rangeOfString("http") == nil
    }
}