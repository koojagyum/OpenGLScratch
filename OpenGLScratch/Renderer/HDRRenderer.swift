//
//  HDRRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 08/08/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class HDRRenderer: MyOpenGLRendererDelegate, MyOpenGLKeyConsumable {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var lightingProgram: MyOpenGLProgram?
    var hdrProgram: MyOpenGLProgram?
    var woodTexture: MyOpenGLTexture?
    var cubeVertexObject: MyOpenGLVertexObject?
    var quadVertexObject: MyOpenGLVertexObject?
    var hdrFramebufferObject: MyOpenGLFramebuffer?

    var hdr = true
    var hdrKeyPressed = false
    var exposure: Float = 1.0

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTexture()

        self.hdrFramebufferObject = MyOpenGLFloatingPointFramebuffer(width: 800, height: 600)
    }

    func prepareProgram() {
        self.lightingProgram = MyOpenGLUtils.createProgramWithName(name: "HDRLighting")
        self.hdrProgram = MyOpenGLUtils.createProgramWithName(name: "HDR")
    }

    func prepareVertices() {
        let cubeVertices: [GLfloat] = [
            // back face
            -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 0.0, // bottom-left
            1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 1.0, // top-right
            1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 0.0, // bottom-right
            1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 1.0, // top-right
            -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 0.0, // bottom-left
            -1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 1.0, // top-left
            // front face
            -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 0.0, // bottom-left
            1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 0.0, // bottom-right
            1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 1.0, // top-right
            1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 1.0, // top-right
            -1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 1.0, // top-left
            -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 0.0, // bottom-left
            // left face
            -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 1.0, 0.0, // top-right
            -1.0,  1.0, -1.0, -1.0,  0.0,  0.0, 1.0, 1.0, // top-left
            -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0.0, 1.0, // bottom-left
            -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0.0, 1.0, // bottom-left
            -1.0, -1.0,  1.0, -1.0,  0.0,  0.0, 0.0, 0.0, // bottom-right
            -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 1.0, 0.0, // top-right
            // right face
            1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 1.0, 0.0, // top-left
            1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0.0, 1.0, // bottom-right
            1.0,  1.0, -1.0,  1.0,  0.0,  0.0, 1.0, 1.0, // top-right
            1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0.0, 1.0, // bottom-right
            1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 1.0, 0.0, // top-left
            1.0, -1.0,  1.0,  1.0,  0.0,  0.0, 0.0, 0.0, // bottom-left
            // bottom face
            -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0.0, 1.0, // top-right
            1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 1.0, 1.0, // top-left
            1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 1.0, 0.0, // bottom-left
            1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 1.0, 0.0, // bottom-left
            -1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 0.0, 0.0, // bottom-right
            -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0.0, 1.0, // top-right
            // top face
            -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0.0, 1.0, // top-left
            1.0,  1.0 , 1.0,  0.0,  1.0,  0.0, 1.0, 0.0, // bottom-right
            1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 1.0, 1.0, // top-right
            1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 1.0, 0.0, // bottom-right
            -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0.0, 1.0, // top-left
            -1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 0.0, 0.0  // bottom-left
        ]
        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3,3,2])

        let quadVertices: [Float] = [
            // positions // texture Coords
            -1.0,  1.0, 0.0, 0.0, 1.0,
            -1.0, -1.0, 0.0, 0.0, 0.0,
            1.0,  1.0, 0.0, 1.0, 1.0,
            1.0, -1.0, 0.0, 1.0, 0.0,
        ]
        self.quadVertexObject = MyOpenGLVertexObject(vertices: quadVertices, alignment: [3,2])
    }

    func prepareTexture() {
        self.woodTexture = MyOpenGLTexture(imageName: "wood", gammaCorrection: true)
    }

    struct Light {
        var position: GLKVector3
        var color: GLKVector3
    }

    func render(_ bounds: NSRect) {
        let lights: [Light] = [
            Light(position: GLKVector3Make(0.0, 0.0, 49.5), color: GLKVector3Make(200.0, 200.0, 200.0)), // backlight
            Light(position: GLKVector3Make(-1.4, -1.9, 9.0), color: GLKVector3Make(0.1, 0.0, 0.0)),
            Light(position: GLKVector3Make(0.0, -1.8, 4.0), color: GLKVector3Make(0.0, 0.0, 0.2)),
            Light(position: GLKVector3Make(0.8, -1.7, 6.0), color: GLKVector3Make(0.0, 0.1, 0.0)),
        ]

        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let hdrTexture = self.hdrFramebufferObject?.draw {
            glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

            let projection = GLKMatrix4MakePerspective(self.camera!.zoom.radian, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = self.camera!.viewMatrix

            self.lightingProgram?.useProgramWith {
                (program) in
                program.setInt(name: "diffuseTexture", value: 0)
                program.setMat4(name: "projection", value: projection)
                program.setMat4(name: "view", value: view)

                self.woodTexture?.useTextureWith(target: GL_TEXTURE0) {
                    for (index, light) in lights.enumerated() {
                        program.setVec3(name: "lights[\(index)].Position" , value: light.position)
                        program.setVec3(name: "lights[\(index)].Color" , value: light.color)
                    }
                    program.setVec3(name: "viewPos", value: camera!.position)
                    // render tunnel
                    program.setInt(name: "inverse_normals", value: 1)
                    let model = GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, 0.0, 25.0), 2.5, 2.5, 27.5)
                    self.renderCube(program: program, model: model)
                }
            }
        }

        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        self.hdrProgram?.useProgramWith {
            (program) in
            program.setInt(name: "hdrBuffer", value: 0)
            program.setInt(name: "hdr", value: self.hdr ? 1 : 0)
            program.setFloat(name: "exposure", value: self.exposure)

            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), hdrTexture!)

            self.quadVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(vertexObject.count))
            }

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }
    }

    func renderCube(program: MyOpenGLProgram, model: GLKMatrix4) {
        program.setMat4(name: "model", value: model)
        self.cubeVertexObject?.useVertexObjectWith {
            (vertexObject) in
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
        }
    }

    func dispose() {
        self.lightingProgram = nil
        self.hdrProgram = nil
        self.woodTexture = nil
        self.cubeVertexObject = nil
        self.quadVertexObject = nil
        self.hdrFramebufferObject = nil
    }

    func processKeyDown(keyCode: UInt16) {
        let exposureIncrement: Float = 0.1
        switch (keyCode) {
        case 12: // 'Q'
            self.exposure = self.exposure > 0.0 ? self.exposure - exposureIncrement : 0.0
        case 14: // 'E'
            self.exposure = self.exposure + exposureIncrement
        case 49: // Space
            self.hdr = !self.hdr
        default:
            break
        }
        print("hdr: \(self.hdr), exposure: \(self.exposure)")
    }
}
