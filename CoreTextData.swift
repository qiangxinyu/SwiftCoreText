//
//  CoreTextData.swift
//  CoreTextOne
//
//  Created by 强新宇 on 16/7/22.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import Foundation
import CoreText


public class CoreTextData: NSObject {
    var frameRef: CTFrameRef?;
    var hieght: CGFloat?;
    var imagesArray: Array<CoreTextImageData>? {
        didSet {
            fillImagePosition();
        }
    };
    var linkArray : Array<CoreTextLinkData>? = [];
    
    override init() {
        super.init();
    }
    
    
    func fillImagePosition() {
        if imagesArray?.count == 0 {
            return;
        }
        
        let lines:NSArray = CTFrameGetLines(frameRef!);
        let lineCount = lines.count;
        let lineOrigins: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.alloc(lineCount);
        CTFrameGetLineOrigins(frameRef!, CFRangeMake(0, 0), lineOrigins);
        
        var imageIndex = 0;
        
        if (imagesArray == nil) {
            return;
        }
        var imageData:CoreTextImageData? = imagesArray![0];
        for i in 0..<lineCount {
            if imageData == nil {
                return;
            }
            
            let line = lines[i] as! CTLine;
            let runObjArray:NSArray = CTLineGetGlyphRuns(line);
            
            for runObj in runObjArray {
                let run: CTRunRef = runObj as! CTRunRef;
                
                let runAttributed: NSDictionary = CTRunGetAttributes(run);
                
                if let _ = (runAttributed[kCTRunDelegateAttributeName as String]) {
                    
                    var runBounds = CGRect();
                    var ascent = CGFloat();
                    var descent = CGFloat();
                    
                    runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil));
                    runBounds.size.height = ascent + descent;
                    
                    let xOffSet = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
                    runBounds.origin.x = lineOrigins[i].x + xOffSet;
                    runBounds.origin.y = lineOrigins[i].y;
                    runBounds.origin.y -= descent;
                    
                    let pathRef = CTFrameGetPath(frameRef!);
                    let colRect = CGPathGetBoundingBox(pathRef);
                    let delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                    
                    imageData?.imagePosition = delegateBounds;
                    imageIndex += 1;
                    
                    if imageIndex == imagesArray?.count {
                        imageData = nil;
                        break;
                    } else {
                        imageData = imagesArray?[imageIndex];
                    }
                    
                } else {
                    continue;
                }
                
                
            }
        }
    }
    
   
}

