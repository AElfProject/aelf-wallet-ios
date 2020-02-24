//
//  QRScannerError.swift
//  QRScanner
//
//  Created by 周斌 on 2019/1/4.
//

import UIKit

public enum QRScannerError: Error {
    case cameraPermissionDenied
    case photoPermissionDenied
    case invalidDevice
    case formatNotSupport
}
