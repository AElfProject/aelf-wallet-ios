//
//  UIApplication+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/30.
//  Copyright © 2019 晋先森. All rights reserved.
//

import Foundation
import AVFoundation

extension UIApplication {
    
    static var isSimulator : Bool {
        // #if (arch(i386) || arch(x86_64)) && os(iOS)
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    
    static func isAllowCamera() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        return authStatus != .restricted && authStatus != .denied
    }
}
