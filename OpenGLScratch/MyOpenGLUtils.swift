//
//  MyOpenGLUtils.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 23/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

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

    static func uniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: inout GLKMatrix4) {
        withUnsafePointer(to: &value.m) {
            $0.withMemoryRebound(to: Float.self, capacity: 16) {
                glUniformMatrix4fv(location, count, transpose, $0)
            }
        }
    }

    static func loadStringFromResource(name: String, type: String) -> String? {
        do {
            let string = try String(contentsOfFile: Bundle.main.path(forResource: name, ofType: type)!)
            return string
        }
        catch {
            return nil
        }
    }
}
