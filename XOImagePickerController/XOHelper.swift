//
//  XOHelper.swift
//  XOImagePickerController
//
//  Created by eru yan on 2019/7/3.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation



struct XOHelper {
    static func formatSecond(_ second: Int) -> String {
        let m = second / 60
        let s = second % 60
        return "\(m):\(s)"
    }
}
