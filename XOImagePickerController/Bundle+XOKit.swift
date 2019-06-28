//
//  Bundle+XOKit.swift
//  XOImagePickerController
//
//  Created by luo fengyuan on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

extension Bundle {
    static func XOKit() -> Bundle {
        let bundle = Bundle(for: XOImagePickerController.classForCoder())
        guard let url = bundle.url(forResource: "XOKit", withExtension: "bundle") else {
            fatalError()
        }
        return Bundle(url: url)!
    }
}

