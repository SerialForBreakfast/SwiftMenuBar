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
        var supportedResolutions = [String]()
        
        statusItem.button?.title = "Fetching..."
        setResolutionObserver()
        
        let screens = ScreenAssets()
        
        guard screens.displayIDs != nil else {
            print("Unable to get displayIDs")
            return
        }
        
        
        
        self.setMenuToResolution()
        statusItem.menu = NSMenu()
        addConfigurationMenuItem()
        
        
        
        screens.listDisplays()
        let numScreens = screens.displayCount
        for i in 0..<numScreens {
            print("Supported Modes for Display: \(i)")
            screens.display(at: i).showModes()
            
        }
        
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
    
    func addConfigurationMenuItems(resolutions: [String]) {
        let seperator = NSMenuItem(title: "Update Resolutions", action: #selector(showSettings), keyEquivalent: "")
        
        statusItem.menu?.addItem(seperator)
        
    }
    
    func showSettings(_ sender: NSMenuItem) {
        //Launch Settings
        
    }
    
}

class ScreenAssets {
    // assume at most 8 display connected
    var maxDisplays:UInt32 = 8
    // actual number of display
    var displayCount:Int = 0
    
    var displayIDs:UnsafeMutablePointer<CGDirectDisplayID>?
    //var onlineDisplayIDs = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity:Int(maxDisplays))
    
    init() {
        // actual number of display
        var displayCount32:UInt32 = 0
        let displayIDsPrealloc = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity:Int(maxDisplays))
        
        
        let error:CGError = CGGetOnlineDisplayList(maxDisplays, displayIDsPrealloc, &displayCount32)
        
        if (error != .success) {
            print("Error on getting online display List.")
            return
        }
        
        displayCount = Int(displayCount32)
        displayIDs = displayIDsPrealloc
    }
    
    // print a list of all displays
    // used by -l
    func listDisplays() {
        if let displayIDs = self.displayIDs {
            for i in 0..<self.displayCount {
                let di = DisplayInfo(displayIDs[i])
                print("Display \(i):  \(di.width) * \(di.height) @ \(di.frequency)Hz")
            }
        }
    }
    
    func display(at:Int) -> DisplayUtil {
        return DisplayUtil(displayIDs![at])
    }
}

class DisplayUtil {
    var displayID:CGDirectDisplayID
    
    init(_ _displayID:CGDirectDisplayID) {
        displayID = _displayID
    }
    
    func showModes() {
        if let modes = self.modes() {
            let nf = NumberFormatter()
            nf.paddingPosition = NumberFormatter.PadPosition.beforePrefix
            nf.paddingCharacter = " " // XXX: Swift does not support padding yet
            nf.minimumIntegerDigits = 3 // XXX
            
            for (_, m) in modes.enumerated() {
                let di = DisplayInfo(displayID:displayID, mode:m)
                print("       \(di.width) * \(di.height) @ \(di.frequency)Hz")
                
        
            }
        }
    }
    
    func modes() -> [CGDisplayMode]? {
        if let modeList = CGDisplayCopyAllDisplayModes(displayID, nil) {
            var modesArray = [CGDisplayMode]()
            
            let count = CFArrayGetCount(modeList)
            for i in 0..<count {
                let modeRaw = CFArrayGetValueAtIndex(modeList, i)
                // https://github.com/FUKUZAWA-Tadashi/FHCCommander
                let mode = unsafeBitCast(modeRaw, to:CGDisplayMode.self)
                
                modesArray.append(mode)
                
            }
            supportedModes = modesArray
            return modesArray
        }
        
        return nil
    }
    
    func mode(width:Int) -> Int? {
        var index:Int?
        if let modesArray = self.modes() {
            for (i, m) in modesArray.enumerated() {
                let di = DisplayInfo(displayID:displayID, mode:m)
                if di.width == width {
                    index = i
                    break
                }
            }
        }
        
        return index
    }
    
    func set(mode:CGDisplayMode) -> Void {
        if mode.isUsableForDesktopGUI() == false {
            print("This mode is unavailable for current desktop GUI")
            return
        }
        
        let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity:1)
        
        let error = CGBeginDisplayConfiguration(config)
        if error == .success {
            let option:CGConfigureOption = CGConfigureOption(rawValue:2) //XXX: permanently
            
            CGConfigureDisplayWithDisplayMode(config.pointee, displayID, mode, nil)
            
            let afterCheck = CGCompleteDisplayConfiguration(config.pointee, option)
            if afterCheck != .success {
                CGCancelDisplayConfiguration(config.pointee)
            }
        }
    }
    
    func set(modeIndex:Int) {
        guard let modes = self.modes(), modeIndex < modes.count else {
            return
        }
        
        self.set(mode:modes[modeIndex])
    }
    
}

// return with, height and frequency info for corresponding displayID
struct DisplayInfo {
    var width, height, frequency:Int
    
    init() {
        width = 0
        height = 0
        frequency = 0
    }
    
    init(_ displayID:CGDirectDisplayID) {
        if let mode = CGDisplayCopyDisplayMode(displayID) {
            self.init(displayID:displayID, mode:mode)
        }
        else {
            self.init()
        }
    }
    
    init(displayID:CGDirectDisplayID, mode:CGDisplayMode) {
        width = mode.width
        height = mode.height
        
        var _frequency = Int( mode.refreshRate )
        
        if _frequency == 0 {
            var link:CVDisplayLink?
            
            CVDisplayLinkCreateWithCGDisplay(displayID, &link)
            
            let time:CVTime = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(link!)
            
            // timeValue is in fact already in Int64
            let timeValue = time.timeValue as Int64
            
            // a hack-y way to do ceil
            let timeScale = Int64(time.timeScale) + timeValue / 2
            
            _frequency = Int( timeScale / timeValue )
        }
        
        frequency = _frequency
    }
}

