//
//  ViewController2.swift
//  MenuBar
//
//  Created by Joseph McCraw on 7/12/17.
//  Copyright © 2017 Joseph McCraw. All rights reserved.
//

import Cocoa

class ViewController2: NSViewController {

    @IBOutlet var textLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("dssa d")
        print(supportedModes)
        for supportedMode in supportedModes {
            textLabel.stringValue = String(describing: textLabel) + "\n \(supportedMode)"
            print("iterating through supported modes")
        }
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    
}
