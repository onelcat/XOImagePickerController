//
//  XOKitResource.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

extension UIImage {
    convenience init?(XOKit named: String) {
        let bundle = Bundle.XOKit()
        print(bundle)
        self.init(named: named,in: bundle, compatibleWith: nil)
    }
    
}
