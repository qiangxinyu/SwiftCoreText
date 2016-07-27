//
//  ViewController.swift
//  SwiftCoreText
//
//  Created by 强新宇 on 16/7/26.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var displayView: DisPlayView;
    
    internal init() {
        displayView = DisPlayView();
        super.init(nibName: nil, bundle: nil);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        displayView = DisPlayView();

        super.init(coder: aDecoder);
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        displayView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 0);
        displayView.backgroundColor = UIColor.grayColor();
        self.view.addSubview(displayView);
        
        let config = FrameParserConfig();
        config.textColor = UIColor.redColor();
        config.width = displayView.frame.width;
        
        let data = FrameParser.parseFileName("Directions.geojson", config: config);
        displayView.data = data;
        
        
        
        displayView.clickImageWithBock { (displayView, imageData) in
            print("click image \(imageData.name)");
        };
        
        displayView.clickLinkWithBlock { (displayView, linkData) in
            print("click link \(linkData.url)");
        };
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

