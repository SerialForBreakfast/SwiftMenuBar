//
//  AppDelegate.swift
//  MenuBar
//
//  Created by Joseph McCraw on 7/12/17.
//  Copyright © 2017 Joseph McCraw. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        statusItem.button?.title = "Fetching..."
        setResolutionObserver()
        
        
        self.setMenuToResolution()
        statusItem.menu = NSMenu()
        addConfigurationMenuItem()
        
       
    }
    
    func setResolutionObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSApplicationDidChangeScreenParameters,
                                               object: NSApplication.shared(),
                                               queue: OperationQueue.main) {
                                                notification -> Void in
                                                print("screen parameters changed")
                                                self.setMenuToResolution()
        }
        
    }
    
    func setMenuToResolution() {
        if let screenInfo: [String : Any] = (NSScreen.main()?.deviceDescription)! {
            //for info in screenInfo {
            if let sizeInfo = screenInfo["NSDeviceSize"] as! CGSize!{
                print(sizeInfo.width)
                print(sizeInfo.height)
                let roundedWidth: Int = Int(sizeInfo.width)
                let roundedHeight: Int = Int(sizeInfo.height)
                let cleanText: String = "\(roundedWidth) x \(roundedHeight)"
                statusItem.button?.title = cleanText
                print(cleanText)
            }
            //}
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func addConfigurationMenuItem() {
        let seperator = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: "")
        statusItem.menu?.addItem(seperator)
    }
    
    func addConfigurationMenuItems() {
        let seperator = NSMenuItem(title: "Update Resolutions", action: #selector(showSettings), keyEquivalent: "")
        statusItem.menu?.addItem(seperator)
    }
    
    func showSettings(_ sender: NSMenuItem) {
        //Launch Settings
        
    }
    
}

