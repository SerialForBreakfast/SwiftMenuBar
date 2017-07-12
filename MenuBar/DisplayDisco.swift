////
////  DisplayDisco.swift
////  MenuBar
////
////  Created by Joseph McCraw on 7/12/17.
////  Copyright © 2017 Joseph McCraw. All rights reserved.
////
//
//import Cocoa
//
//class DisplayDisco: NSObject {
//    //Max 8 displays
//    var maxDisplays:UInt32 = 8
//    var displayCount:Int = 0
//    
//    var displayIDs:UnsafeMutablePointer<CGDirectDisplayID>
//    
//    init() {
//        var displayCount32:UInt32 = 0
//        
//        let displayIDsPrealloc = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(maxDisplays))
//        let error:CGError = CGGetOnlineDisplayList(maxDisplays, displayIDsPrealloc, &displayCount32)
//        
//        if (error != .success) {
//            print("Error getting online display list")
//            return
//        }
//        displayCount = Int(displayCount32)
//        displayIDs = displayIDsPrealloc
//        
//    }
//    
//    func listDisplays() {
//        if let displayIDs = self.displayIDs {
//            for i in 0..<self.displayCount {
//                let di = DisplayInfo(displayIDs[i])
//                print("Display \(i):  \(di.width) * \(di.height) @ \(di.frequency)Hz")
//            }
//        }
//    }
//    
//    func display(at:Int) -> DisplayUtil {
//        return DisplayUtil(displayIDs![at])
//    }
//}
//
//class DisplayUtil {
//    var displayID:CGDirectDisplayID
//    
//    init(_ _displayID:CGDirectDisplayID) {
//        displayID = _displayID
//    }
//    
//    func showModes() {
//        if let modes = self.modes() {
//            let nf = NumberFormatter()
//            nf.paddingPosition = NumberFormatter.PadPosition.beforePrefix
//            nf.paddingCharacter = " " // XXX: Swift does not support padding yet
//            nf.minimumIntegerDigits = 3 // XXX
//            
//            for (_, m) in modes.enumerated() {
//                let di = DisplayInfo(displayID:displayID, mode:m)
//                print("       \(di.width) * \(di.height) @ \(di.frequency)Hz")
//            }
//        }
//    }
//    
//    func modes() -> [CGDisplayMode]? {
//        if let modeList = CGDisplayCopyAllDisplayModes(displayID, nil) {
//            var modesArray = [CGDisplayMode]()
//            
//            let count = CFArrayGetCount(modeList)
//            for i in 0..<count {
//                let modeRaw = CFArrayGetValueAtIndex(modeList, i)
//                // https://github.com/FUKUZAWA-Tadashi/FHCCommander
//                let mode = unsafeBitCast(modeRaw, to:CGDisplayMode.self)
//                
//                modesArray.append(mode)
//            }
//            
//            return modesArray
//        }
//        
//        return nil
//    }
//    
//    func mode(width:Int) -> Int? {
//        var index:Int?
//        if let modesArray = self.modes() {
//            for (i, m) in modesArray.enumerated() {
//                let di = DisplayInfo(displayID:displayID, mode:m)
//                if di.width == width {
//                    index = i
//                    break
//                }
//            }
//        }
//        
//        return index
//    }
//    
//    func set(mode:CGDisplayMode) -> Void {
//        if mode.isUsableForDesktopGUI() == false {
//            print("This mode is unavailable for current desktop GUI")
//            return
//        }
//        
//        let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity:1)
//        
//        let error = CGBeginDisplayConfiguration(config)
//        if error == .success {
//            let option:CGConfigureOption = CGConfigureOption(rawValue:2) //XXX: permanently
//            
//            CGConfigureDisplayWithDisplayMode(config.pointee, displayID, mode, nil)
//            
//            let afterCheck = CGCompleteDisplayConfiguration(config.pointee, option)
//            if afterCheck != .success {
//                CGCancelDisplayConfiguration(config.pointee)
//            }
//        }
//    }
//    
//    func set(modeIndex:Int) {
//        guard let modes = self.modes(), modeIndex < modes.count else {
//            return
//        }
//        
//        self.set(mode:modes[modeIndex])
//    }
//    
//}
//
//// return with, height and frequency info for corresponding displayID
//struct DisplayInfo {
//    var width, height, frequency:Int
//    
//    init() {
//        width = 0
//        height = 0
//        frequency = 0
//    }
//    
//    init(_ displayID:CGDirectDisplayID) {
//        if let mode = CGDisplayCopyDisplayMode(displayID) {
//            self.init(displayID:displayID, mode:mode)
//        }
//        else {
//            self.init()
//        }
//    }
//    
//    init(displayID:CGDirectDisplayID, mode:CGDisplayMode) {
//        width = mode.width
//        height = mode.height
//        
//        var _frequency = Int( mode.refreshRate )
//        
//        if _frequency == 0 {
//            var link:CVDisplayLink?
//            
//            CVDisplayLinkCreateWithCGDisplay(displayID, &link)
//            
//            let time:CVTime = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(link!)
//            
//            // timeValue is in fact already in Int64
//            let timeValue = time.timeValue as Int64
//            
//            // a hack-y way to do ceil
//            let timeScale = Int64(time.timeScale) + timeValue / 2
//            
//            _frequency = Int( timeScale / timeValue )
//        }
//        
//        frequency = _frequency
//    }
//}
//
