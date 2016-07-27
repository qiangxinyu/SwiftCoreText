//
//  FrameParserConfig.swift
//  CoreTextOne
//
//  Created by 强新宇 on 16/7/25.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit

public func RGB(red: Float, green: Float, blue: Float) -> UIColor {
    return UIColor(colorLiteralRed: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1);
}

public class FrameParserConfig: NSObject {
    var width: CGFloat;
    var fontSize: CGFloat;
    var lineSpace: CGFloat;
    var textColor: UIColor;
    
    override init() {
        width = 200;
        fontSize = 16;
        lineSpace = 8;
        textColor = RGB(108, green: 108, blue: 108);
        super.init();
    }
}