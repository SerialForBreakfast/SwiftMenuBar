//
//  ViewController.swift
//  MenuBar
//
//  Created by Joseph McCraw on 7/12/17.
//  Copyright © 2017 Joseph McCraw. All rights reserved.
//

import Cocoa

var supportedModes = [CGDisplayMode]()

class ViewController: NSViewController {

    @IBOutlet var textLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("dssa d")
        print(supportedModes)
        for supportedMode in supportedModes {
            textLabel.stringValue = String(describing: textLabel) + "\n \(supportedMode)"
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

