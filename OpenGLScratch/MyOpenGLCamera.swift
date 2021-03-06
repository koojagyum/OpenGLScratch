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
    let movementSpeed: GLfloat = SPEED
    let mouseSensitivity: GLfloat = SENSITIVITY
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

    func reset(position: GLKVector3, worldUp: GLKVector3) {
        self.position = position
        self.worldUp = worldUp
        self.pitch = PITCH
        self.yaw = YAW
        self.zoom = ZOOM
    }

    init(position: GLKVector3, worldUp: GLKVector3) {
        self.position = position
        self.worldUp = worldUp
    }
}
