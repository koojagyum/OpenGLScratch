//
//  BloomRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 12/08/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class BloomRenderer: MyOpenGLRendererDelegate, MyOpenGLKeyConsumable {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var bloom = true
    var exposure: Float = 1.0

    var bloomSceneProgram: MyOpenGLProgram?
    var bloomLightboxProgram: MyOpenGLProgram?
    var bloomBlurProgram: MyOpenGLProgram?
    var bloomBlendProgram: MyOpenGLProgram?

    var hdrFramebuffer: MyOpenGLFloatingPointFramebufferMultiTarget?
    var pingpongFramebuffer1: MyOpenGLFramebuffer?
    var pingpongFramebuffer2: MyOpenGLFramebuffer?

    var woodTexture: MyOpenGLTexture?
    var containerTexture: MyOpenGLTexture?

    var cubeVertexObject: MyOpenGLVertexObject?
    var quadVertexObject: MyOpenGLVertexObject?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTexture()

        self.hdrFramebuffer = MyOpenGLFloatingPointFramebufferMultiTarget(width: 800, height: 600)
        self.pingpongFramebuffer1 = MyOpenGLFloatingPointFramebuffer(width: 800, height: 600)
        self.pingpongFramebuffer2 = MyOpenGLFloatingPointFramebuffer(width: 800, height: 600)

        glBindTexture(GLenum(GL_TEXTURE_2D), self.pingpongFramebuffer1!.tex)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glBindTexture(GLenum(GL_TEXTURE_2D), self.pingpongFramebuffer2!.tex)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }

    func prepareProgram() {
        self.bloomSceneProgram = MyOpenGLUtils.createProgramWithName(name: "BloomScene")
        self.bloomLightboxProgram = MyOpenGLUtils.createProgramWithNames(vshName: "BloomScene", fshName: "BloomLightbox")
        self.bloomBlurProgram = MyOpenGLUtils.createProgramWithNames(vshName: "HDR", fshName: "BloomBlur")
        self.bloomBlendProgram = MyOpenGLUtils.createProgramWithNames(vshName: "HDR", fshName: "BloomBlend")
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
        self.containerTexture = MyOpenGLTexture(imageName: "container2", gammaCorrection: true)
    }

    struct Light {
        var position: GLKVector3
        var color: GLKVector3
    }

    func render(_ bounds: NSRect) {
        let lights: [Light] = [
            Light(position: GLKVector3Make(+0.0, +0.5, +1.5), color: GLKVector3Make(2.0, 2.0, 2.0)), // backlight
            Light(position: GLKVector3Make(-4.0, +0.5, -3.0), color: GLKVector3Make(1.5, 0.0, 0.0)),
            Light(position: GLKVector3Make(+3.0, +0.5, +1.0), color: GLKVector3Make(0.0, 0.0, 1.5)),
            Light(position: GLKVector3Make(-8.0, +2.4, -1.0), color: GLKVector3Make(0.0, 1.5, 0.0)),
        ]

        glEnable(GLenum(GL_DEPTH_TEST))
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        // 1. render scene into floating point framebuffer
        _ = self.hdrFramebuffer?.draw {
            glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

            let projection = GLKMatrix4MakePerspective(self.camera!.zoom.radian, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = self.camera!.viewMatrix

            self.bloomSceneProgram?.useProgramWith {
                (program) in
                program.setInt(name: "diffuseTexture", value: 0)
                program.setMat4(name: "projection", value: projection)
                program.setMat4(name: "view", value: view)
                program.setVec3(name: "viewPos", value: camera!.position)
                for (index, light) in lights.enumerated() {
                    program.setVec3(name: "lights[\(index)].Position" , value: light.position)
                    program.setVec3(name: "lights[\(index)].Color" , value: light.color)
                }

                // set lighting uniforms
                self.woodTexture?.useTextureWith(target: GL_TEXTURE0) {
                    // create one large cube that acts as the floor
                    self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, -1.0, 0.0), 12.5, 0.5, 12.5))
                }
                
                self.containerTexture?.useTextureWith(target: GL_TEXTURE0) {
                    // create multiple cubes as the scenery
                    self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, 1.5, 0.0), 0.5, 0.5, 0.5))
                    self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(2.0, 0.0, 1.0), 0.5, 0.5, 0.5))
                    self.renderCube(program: program, model: GLKMatrix4Rotate(GLKMatrix4MakeTranslation(-1.0, -1.0, 2.0), Float(60.0).radian, 1.0, 0.0, 1.0))
                    self.renderCube(program: program, model: GLKMatrix4Rotate(GLKMatrix4MakeTranslation(0.0, 2.7, 4.0), Float(23.0).radian, 1.0, 0.0, 1.0))
                    self.renderCube(program: program, model: GLKMatrix4Rotate(GLKMatrix4MakeTranslation(-2.0, 1.0, -3.0), Float(124.0).radian, 1.0, 0.0, 1.0))
                    self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(-3.0, 0.0, 0.0), 0.5, 0.5, 0.5))
                }
            }

            // finally show all the light sources as bright cubes
            self.bloomLightboxProgram?.useProgramWith {
                (program) in
                program.setMat4(name: "projection", value: projection)
                program.setMat4(name: "view", value: view)

                for (_, light) in lights.enumerated() {
                    let model = GLKMatrix4Scale(GLKMatrix4MakeTranslation(light.position.x, light.position.y, light.position.z), 0.25, 0.25, 0.25)
                    program.setVec3(name: "lightColor", value: light.color)
                    self.renderCube(program: program, model: model)
                }
            }
        }

        // 2. blur bright fragments with two-pass Gaussian Blur
        let amount = 10
        var horizontal = true
        var firstIteration = true
        self.bloomBlurProgram?.useProgramWith {
            (program) in
            program.setInt(name: "image", value: 0)

            for _ in 1...amount {
                program.setInt(name: "horizontal", value: horizontal ? 1 : 0)
                let (fbo, fboOther) = horizontal ? (self.pingpongFramebuffer1, self.pingpongFramebuffer2) : (self.pingpongFramebuffer2, self.pingpongFramebuffer1)
                _ = fbo!.draw {
                    glClear(GLenum(GL_DEPTH_BUFFER_BIT))

                    let textureId = firstIteration ? hdrFramebuffer!.tex2 : fboOther!.tex
                    glActiveTexture(GLenum(GL_TEXTURE0))
                    glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
                    self.renderQuad()
                }
                horizontal = !horizontal
                firstIteration = false
            }
        }

        // 3. now render floating point color buffer to 2D quad and tonemap HDR colors to default framebuffer's (clamped) color range
        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        bloomBlendProgram?.useProgramWith {
            (program) in
            program.setInt(name: "scene", value: 0)
            program.setInt(name: "bloomBlur", value: 1)
            program.setInt(name: "bloom", value: self.bloom ? 1 : 0)
            program.setFloat(name: "exposure", value: self.exposure)

            let blurredFbo = horizontal ? self.pingpongFramebuffer2 : self.pingpongFramebuffer1
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), hdrFramebuffer!.tex1)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), blurredFbo!.tex)

            self.renderQuad()

            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func renderCube(program: MyOpenGLProgram, model: GLKMatrix4) {
        program.setMat4(name: "model", value: model)
        self.cubeVertexObject?.useVertexObjectWith {
            (vertexObject) in
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
        }
    }

    func renderQuad() {
        self.quadVertexObject?.useVertexObjectWith {
            (vertexObject) in
            glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(vertexObject.count))
        }
    }

    func dispose() {
        self.bloomSceneProgram = nil
        self.bloomLightboxProgram = nil
        self.bloomBlurProgram = nil
        self.bloomBlendProgram = nil

        self.hdrFramebuffer = nil
        self.pingpongFramebuffer1 = nil
        self.pingpongFramebuffer2 = nil

        self.woodTexture = nil
        self.containerTexture = nil

        self.cubeVertexObject = nil
        self.quadVertexObject = nil
    }

    func processKeyDown(keyCode: UInt16) {
        let exposureIncrement: Float = 0.1
        switch (keyCode) {
        case 12: // 'Q'
            self.exposure = self.exposure > 0.0 ? self.exposure - exposureIncrement : 0.0
            print("exposure dn: \(self.exposure)")
        case 14: // 'E'
            self.exposure = self.exposure + exposureIncrement
            print("exposure up: \(self.exposure)")
        case 49: // Space
            self.bloom = !self.bloom
            print("bloom: \(self.bloom)")
        default:
            break
        }
    }
}
