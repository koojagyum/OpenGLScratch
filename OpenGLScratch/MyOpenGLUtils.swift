//
//  MyOpenGLUtils.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 23/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class MyOpenGLUtils {
    static func DEGREE2RADIAN(_ degree: Float) -> Float {
        return degree * Float.pi / 180.0
    }

    static func BUFFER_OFFSET(_ i: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: i)
    }

    static func keyCodeToMovement(keyCode: UInt16) -> MyOpenGLCameraMovement {
        switch keyCode {
        case 0: // a
            return .LEFT
        case 1: // s
            return .BACKWARD
        case 2: // d
            return .RIGHT
        case 13: // w
            return .FORWARD
        default:
            return .NONE
        }
    }
}
