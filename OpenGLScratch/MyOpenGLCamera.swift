//
//  MyOpenGLCamera.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 23/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

let YAW: GLfloat = -90.0
let PITCH: GLfloat = 0.0
let SPEED: GLfloat = 3.0
let SENSITIVITY: GLfloat = 0.25
let ZOOM: GLfloat = 45.0

enum MyOpenGLCameraMovement {
    case FORWARD, BACKWARD, LEFT, RIGHT, NONE
}

extension GLKVector3 {
    static func * (left: GLKVector3, right: Float) -> GLKVector3 {
        return GLKVector3Make(left.x * right, left.y * right, left.z * right)
    }
    @discardableResult
    static func += (left: inout GLKVector3, right: GLKVector3) -> GLKVector3 {
        left = GLKVector3Add(left, right)
        return left
    }
    @discardableResult
    static func -= (left: inout GLKVector3, right: GLKVector3) -> GLKVector3 {
        left = GLKVector3Subtract(left, right)
        return left
    }
}

extension GLfloat {
    var degree: GLfloat { return self }
    var radian: GLfloat { return MyOpenGLUtils.DEGREE2RADIAN(self) }
}

class MyOpenGLCamera {
    // Camera Attributes
    var position: GLKVector3
    var worldUp: GLKVector3
    var front: GLKVector3 {
        return GLKVector3Make(cosf(self.yaw.radian) * cosf(self.pitch.radian), sinf(self.pitch.radian), sinf(self.yaw.radian))
    }
    var up: GLKVector3 {
        let upWithoutNorm = GLKVector3CrossProduct(self.right, self.front)
        return GLKVector3Normalize(upWithoutNorm)
    }
    var right: GLKVector3 {
        let rightWithoutNorm = GLKVector3CrossProduct(self.front, self.worldUp)
        return GLKVector3Normalize(rightWithoutNorm)
    }

    // Euler Angles (with radians)
    var yaw: GLfloat = YAW
    var pitch: GLfloat = PITCH

    // Camera options
    var movementSpeed: GLfloat = SPEED
    var mouseSensitivity: GLfloat = SENSITIVITY
    var zoom: GLfloat = ZOOM

    var viewMatrix: GLKMatrix4 {
        let target: GLKVector3 = GLKVector3Add(self.position, self.front)
        return GLKMatrix4MakeLookAt(
            self.position.x, self.position.y, self.position.z,
            target.x, target.y, target.z,
            self.up.x, self.up.y, self.up.z)
    }

    func processKeyboard(_ direction: MyOpenGLCameraMovement, _ deltaTime: GLfloat) {
        let velocity = self.movementSpeed * deltaTime
        switch direction {
        case .FORWARD:
            self.position += self.front * velocity
        case .BACKWARD:
            self.position -= self.front * velocity
        case .LEFT:
            self.position -= self.right * velocity
        case .RIGHT:
            self.position += self.right * velocity
        default:
            break
        }
    }

    func processMouseMovement(_ xoffset: GLfloat, _ yoffset: GLfloat, _ constrainPitch: Bool) {
        self.yaw += self.mouseSensitivity * xoffset
        self.pitch += self.mouseSensitivity * yoffset

        // Make sure that when pitch is out of bounds, screen doesn't get flipped
        if constrainPitch {
            if self.pitch > +89.0 {
                self.pitch = +89.0
            }
            if self.pitch < -89.0 {
                self.pitch = -89.0
            }
        }
    }

    func processMouseScroll(_ yoffset: GLfloat) {
        if self.zoom >= 1.0 && self.zoom <= 45.0 {
            self.zoom -= yoffset
        }
        if self.zoom <= 1.0 {
            self.zoom = 1.0
        }
        if self.zoom >= 45.0 {
            self.zoom = 45.0
        }
    }

    init(position: GLKVector3, worldUp: GLKVector3) {
        self.position = position
        self.worldUp = worldUp
    }
}
