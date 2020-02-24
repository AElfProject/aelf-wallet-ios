//
//  QRScannerPermissions.swift
//  QRScanner
//
//  Created by 周斌 on 2018/11/30.
//

import UIKit
import Photos
public class QRScannerPermissions: NSObject {
    
    public static func authorizePhotoWith(comletion:@escaping (Bool) -> Void) {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case PHAuthorizationStatus.authorized:
            comletion(true)
        case PHAuthorizationStatus.denied, PHAuthorizationStatus.restricted:
            comletion(false)
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    comletion(status == PHAuthorizationStatus.authorized ? true:false)
                }
            })
        default: break
        }
    }
    
    public static func authorizeCameraWith(comletion:@escaping (Bool) -> Void ) {
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch granted {
        case .authorized:
            comletion(true)
        case .denied:
            comletion(false)
        case .restricted:
            comletion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async {
                    comletion(granted)
                }
            })
        default: break
        }
    }
    
    public static func openSystemPrivacySetting() {
        let appSetting = URL(string: UIApplication.openSettingsURLString)
        
        if appSetting != nil {
            if #available(iOS 10, *) {
                UIApplication.shared.open(appSetting!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appSetting!)
            }
        }
    }
}
