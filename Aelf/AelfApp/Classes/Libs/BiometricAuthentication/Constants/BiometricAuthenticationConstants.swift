//
//  BiometricAuthenticationConstants.swift
//  BiometricAuthentication
//
//  Created by Rushi on 27/10/17.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation
import LocalAuthentication

let kBiometryNotAvailableReason = "Biometric authentication is not available for this device.".localized()

/// ****************  Touch ID  ****************** ///

let kTouchIdAuthenticationReason = "Confirm your fingerprint".localized()
let kTouchIdPasscodeAuthenticationReason = "Touch ID is locked".localized()

/// Error Messages Touch ID
let kSetPasscodeToUseTouchID = "Please set device passcode to use Touch ID".localized()
let kNoFingerprintEnrolled = "There are no fingerprints enrolled".localized()
let kDefaultTouchIDAuthenticationFailedReason = "Touch ID does not recognize".localized()

/// ****************  Face ID  ****************** ///

let kFaceIdAuthenticationReason = "Confirm your face to authenticate.".localized()
let kFaceIdPasscodeAuthenticationReason = "Face ID is locked".localized()

/// Error Messages Face ID
let kSetPasscodeToUseFaceID = "Please set device passcode to use Face ID".localized()
let kNoFaceIdentityEnrolled = "There is no face enrolled".localized()
let kDefaultFaceIDAuthenticationFailedReason = "Face ID does not recognize".localized()
