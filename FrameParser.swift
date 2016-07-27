//
//  FrameParser.swift
//  CoreTextOne
//
//  Created by 强新宇 on 16/7/25.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit

public class CallData: NSObject {
    let width: CGFloat;
    let height: CGFloat;
    
    class func object(pointer: UnsafeMutablePointer<Void>) -> CallData {
        return Unmanaged<CallData>.fromOpaque(COpaquePointer(pointer)).takeRetainedValue()
    }
    
    init(_ width: CGFloat, _ height: CGFloat) {
        self.width = width;
        self.height = height;
        super.init();
    }
}

public class FrameParser: NSObject {
    
    public class func parseContent(content: String, config: FrameParserConfig) -> CoreTextData {
        let attributeds = attriubtedsWithConfig(config);
        let contentString = NSAttributedString(string: content, attributes: attributeds);
        return parseAttContent(contentString, config: config);
    }
    
    
    
    public class func parseAttContent(attContent: NSAttributedString, config: FrameParserConfig) -> CoreTextData {
        let framesetter = CTFramesetterCreateWithAttributedString(attContent as CFAttributedString);
        
        let restrictSize = CGSizeMake(config.width, .max);
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
        let textHeight = coreTextSize.height;
        
        let frame = createFrameWithFramesetter(framesetter, config: config, height: textHeight);

        let data = CoreTextData();
        data.frameRef = frame;
        data.hieght = textHeight;
        return data;
    }
    
    
    public class func parseFileName(fileName:String, config: FrameParserConfig) -> CoreTextData? {
        var imagesArray = Array<CoreTextImageData>();
        var linksArray = Array<CoreTextLinkData>();
        let content = loadFileName(fileName, config: config, imagesArray: &imagesArray , linksArray: &linksArray);
        if content != nil {
            let data = parseAttContent(content!, config: config);
            data.imagesArray = imagesArray;
            data.linkArray = linksArray;
            return data;
        }
        return nil;
    }
    
    
    
    
    
    
    // MARK: --- Inner Method
    class func attriubtedsWithConfig(config: FrameParserConfig) -> Dictionary<String, AnyObject> {
        let fontSize = config.fontSize;
        let fontRef = CTFontCreateWithName("ArialMT", fontSize, nil);
        var lineSpacing = config.lineSpace;
        let kNumberOfSetting:CFIndex = 3;
        
        let theSetting = [CTParagraphStyleSetting(spec: .LineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing),
                          CTParagraphStyleSetting(spec: .MaximumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing),
                          CTParagraphStyleSetting(spec: .MinimumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpacing)];
        

        
        let theParagrapgRef = CTParagraphStyleCreate(theSetting, kNumberOfSetting);
        
        let textColor = config.textColor;
        var dict = Dictionary<String, AnyObject>();
        dict[kCTForegroundColorAttributeName as String] = textColor.CGColor;
        dict[kCTFontAttributeName as String] = fontRef;
        dict[kCTParagraphStyleAttributeName as String] = theParagrapgRef;
        
        return dict;
    }
    
    class func createFrameWithFramesetter(framesetter: CTFramesetterRef, config: FrameParserConfig, height: CGFloat) -> CTFrameRef {
        let path = CGPathCreateMutable();
        CGPathAddRect(path, nil, CGRectMake(0, 0, config.width, height));
        
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
        return frame;
    }
    
    
    class func loadFileName(fileName: String, config: FrameParserConfig, inout imagesArray: Array<CoreTextImageData>, inout linksArray: Array<CoreTextLinkData>) -> NSAttributedString? {
        
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil) {
            let data = NSData(contentsOfFile:path);
            let result = NSMutableAttributedString();
            
            if data == nil {
                return nil;
            }
            
            do {
                let array = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                if array is Array<Dictionary<String, AnyObject>> {
                    let listArray: Array<Dictionary<String, AnyObject>> = array as! Array<Dictionary<String, AnyObject>>;
                    for dic in listArray {
                        if let type = dic["type"] as? String {
                            if type == "txt" {
                                let attributedString = parseAttributedContentFormDictionary(dic, config: config);
                                if attributedString != nil {
                                    result.appendAttributedString(attributedString!);
                                }
                            } else if type == "img" {
                                let imageData = CoreTextImageData();
                                imageData.name = dic["name"] as? String;
                                imageData.position = result.length;
                                imagesArray.append(imageData);
                                
                                let attributedString = parseImageDataFromDictionary(dic, config: config);
                                result.appendAttributedString(attributedString);
                            } else if type == "link" {
                                
                                let startPos = result.length;

                                
                                let attributedString = parseAttributedContentFormDictionary(dic, config: config);
                                if attributedString != nil {
                                    result.appendAttributedString(attributedString!);
                                }
                                
                                let length = result.length - startPos;
                                let linkRange = NSMakeRange(startPos, length);
                                
                                let linkData = CoreTextLinkData();
                                linkData.url = dic["url"] as? String;
                                linkData.title = dic["content"] as? String;
                                linkData.range = linkRange;
                                linksArray.append(linkData);
                            }
                        }
                        
                    }
                    return result;
                }
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
            
        }
        return nil;
    }
    
    class func parseAttributedContentFormDictionary(dic: Dictionary<String, AnyObject>, config: FrameParserConfig) -> NSAttributedString? {
        var attbuiteds = attriubtedsWithConfig(config);
        
        if let colorName = dic["color"] as? String {
            let color = colorFormcColorName(colorName);
            attbuiteds[kCTForegroundColorAttributeName as String] = color?.CGColor;
        }
        
        if let fontSize = dic["size"] as? CGFloat {
            if fontSize != 0 {
                let fontRef = CTFontCreateWithName("ArialMT", fontSize, nil);
                attbuiteds[kCTFontAttributeName as String] = fontRef;
            }
        }
        
        if let content = dic["content"] as? String {
            return NSAttributedString(string: content, attributes: attbuiteds);
        }
        
        return nil;
        
    }
    
    class func colorFormcColorName(colorName: String) -> UIColor? {
        if colorName == "blue" {
            return UIColor.blueColor();
        } else if colorName == "red" {
            return UIColor.redColor();
        } else if colorName == "black" {
            return UIColor.blackColor();
        }
        return nil;
    }
    
 
    
    class func parseImageDataFromDictionary(dic: Dictionary<String, AnyObject>, config: FrameParserConfig) -> NSAttributedString {
        
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion, dealloc: { (refCon) in
            
            }, getAscent: { (refCon:UnsafeMutablePointer<Void>) -> CGFloat in
                return UnsafePointer<MyRunExtent>(refCon).memory.ascent;
            }, getDescent: { (refCon) -> CGFloat in
                return 0;
            }) { (refCon) -> CGFloat in
                return UnsafePointer<MyRunExtent>(refCon).memory.width;
        }
        
        struct MyRunExtent {
            let ascent: CGFloat
            let descent: CGFloat
            let width: CGFloat
        }
        
        let extentBuffer = UnsafeMutablePointer<MyRunExtent>.alloc(1)
        extentBuffer.initialize(MyRunExtent(ascent: dic["height"] as! CGFloat, descent: 0, width: dic["width"] as! CGFloat))
        
        
        let delegate = CTRunDelegateCreate(&callbacks, extentBuffer);
        
        var content = " ";
        
        content = content.stringByAppendingString("\n");
        
        let space = NSMutableAttributedString(string: content);
        CFAttributedStringSetAttribute(space as CFMutableAttributedStringRef, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
        return space;
    }
    
    
    
    
}