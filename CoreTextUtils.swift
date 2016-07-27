//
//  CoreTextUtils.swift
//  CoreTextOne
//
//  Created by 强新宇 on 16/7/25.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit

public class CoreTextUtils: NSObject {
    public class func touchLinkInView(view: UIView, point: CGPoint, data: CoreTextData?) -> CoreTextLinkData? {
        
        if data == nil {
            return nil;
        }
        
        if data!.linkArray == nil {
            return nil;
        }
        
        let textFrame = data!.frameRef!;
        let lines = CTFrameGetLines(textFrame);
        
        let count = CFArrayGetCount(lines);
        
        //获取 每一行的 origin坐标
        let origins = UnsafeMutablePointer<CGPoint>.alloc(count);
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        //翻转坐标系
        var transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
        transform = CGAffineTransformScale(transform, 1, -1);
        
        for i in 0..<count {
            let linePoint = origins[i];

            let liness = lines as [AnyObject];
            

            let line: CTLineRef = liness[i] as! CTLineRef;

            //获取每一行 的 CGRect信息
            let flippedRect = getLineBounds(line, point: linePoint);
            let rect = CGRectApplyAffineTransform(flippedRect, transform);
            
            
            
            if CGRectContainsPoint(rect, point) {
                //将点击的坐标 转换成 相对于当前的坐标
                let relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
                
                //获得当前点击坐标对于的字符串偏移
                let index = CTLineGetStringIndexForPosition(line, relativePoint);
                
                //判断这个偏移 是否在我们的连接中
                return linkAtIndex(index, linkArray: data!.linkArray!);
            }
        }
        
        
        return nil;
    }
    
    
    //MARK: ---- Inner Method
    
    class func getLineBounds(bounds: CTLineRef, point: CGPoint) -> CGRect {
        var ascent = CGFloat();
        var descent = CGFloat();
        var leading = CGFloat();
        let width = CGFloat(CTLineGetTypographicBounds(bounds, &ascent, &descent, &leading));
        let height = ascent + descent;
        return CGRectMake(point.x, point.y - ascent, width, height);
    }
    
    class func linkAtIndex(index: CFIndex, linkArray: Array<CoreTextLinkData>) -> CoreTextLinkData? {
        for data in linkArray {
            if NSLocationInRange(index, data.range!) {
                return data;
            }
        }
        return nil;
    }
}