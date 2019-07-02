//
//  Bundle+XOKit.swift
//  XOImagePickerController
//
//  Created by hao shuai on 2019/6/28.
//  Copyright © 2019 luo fengyuan. All rights reserved.
//

import Foundation

fileprivate var XOKitBundle: Bundle?

extension Bundle {
//    lazy var XOKit: Bundle = {
//        let bundle = Bundle(for: XOImagePickerController.classForCoder())
//        guard let url = bundle.url(forResource: "XOKit", withExtension: "bundle") else {
//            fatalError()
//        }
//        return Bundle(url: url)!
//    }()
    
    static func XOKit() -> Bundle? {
        if let bundle = XOKitBundle {
            return bundle
        }
        
        let bundle = Bundle(for: XOImagePickerController.classForCoder())
        guard let url = bundle.url(forResource: "XOKit", withExtension: "bundle") else {
            fatalError()
        }
        XOKitBundle = Bundle(url: url)
        return XOKitBundle
    }
}

