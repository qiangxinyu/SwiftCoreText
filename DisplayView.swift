//
//  DisplayView.swift
//  CoreTextOne
//
//  Created by 强新宇 on 16/7/26.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit

public class DisPlayView: UIView , UIGestureRecognizerDelegate{
    public typealias ClickImageBlock = (displayView: DisPlayView, imageData: CoreTextImageData) -> ();
    public typealias ClickLinkBlock  = (displayView: DisPlayView, linkData: CoreTextLinkData) -> ();
    
    
    var tap: UITapGestureRecognizer?;
    var data: CoreTextData? {
        willSet {
            if newValue != nil {
                var rect = self.frame;
                rect.size.height = newValue!.hieght!;
                self.frame = rect;
                
                setNeedsDisplay();
            }
            
        }
    }
    
    var clickImageBlock: ClickImageBlock?;
    var clickLinkBlock : ClickLinkBlock?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        setupEvents();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setupEvents();
    }
    
    init() {
        super.init(frame: CGRectZero);
        setupEvents();
    }
    
    
    //MARK: -- Method
    public func clickImageWithBock(block: ClickImageBlock) {
        clickImageBlock = block;
    }
    public func clickLinkWithBlock(block: ClickLinkBlock) {
        clickLinkBlock = block;
    }
    

    
    
    //MARK: -- Inner Method

    func setupEvents() {
        tap = UITapGestureRecognizer(target: self, action: #selector(userTapGestureDetected(_:)));
        tap?.delegate = self;
        self.addGestureRecognizer(tap!);
        self.userInteractionEnabled = true;
    }
    
    func userTapGestureDetected(reconginzer: UIGestureRecognizer) {
        let point = reconginzer.locationInView(self);
        
        if data?.imagesArray == nil {
            return;
        }
        for imageData:CoreTextImageData in (data?.imagesArray)! {
            let imageRect = imageData.imagePosition;
            var imagePosition = imageRect?.origin;
            
            //翻转坐标
            imagePosition?.y = self.bounds.size.height - imagePosition!.y - (imageRect?.size.height)!;
            let rect = CGRectMake(imagePosition!.x, imagePosition!.y, imageRect!.size.width, imageRect!.size.height);
            
            //检测 point 是否在 rect 中
            if CGRectContainsPoint(rect, point) {
                clickImageBlock?(displayView: self, imageData: imageData);
                return;
            }
        }
        
        let linkData = CoreTextUtils.touchLinkInView(self, point: point, data: data);
        if linkData != nil {
            clickLinkBlock?(displayView: self, linkData: linkData!);
        }
    }
    
    override public func drawRect(rect: CGRect) {
        if data == nil {
            return;
        }
        
        let context = UIGraphicsGetCurrentContext();
        if context == nil {
            return;
        }
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1, -1);
        
        CTFrameDraw(data!.frameRef!, context!);
        
        for imageData: CoreTextImageData in data!.imagesArray! {
            let image = UIImage(named: imageData.name!);
            if image != nil {
                CGContextDrawImage(context, imageData.imagePosition!, image?.CGImage);
            }
        }
        
    }
    
}