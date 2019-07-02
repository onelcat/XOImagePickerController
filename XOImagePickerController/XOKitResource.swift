//
//  XOKitResource.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

extension UIImage {
    convenience init?(XOKit name: String) {
        let bundle = Bundle.XOKit()
        print(bundle)
        self.init(named: name,in: bundle, compatibleWith: nil)
    }
    
}
