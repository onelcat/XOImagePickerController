//
//  XOKitResource.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    convenience init?(XOKit named: String) {
        let bundle = Bundle.XOKit()
        assert(bundle != nil)
        debugPrint("bundle data", bundle ?? "XXXX", named)
        self.init(named: named,in: bundle, compatibleWith: nil)
    }
}
