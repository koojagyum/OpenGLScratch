//
//  MSAARenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 06/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class MSAARenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var cubeProgram: MyOpenGLProgram?
    var quadProgram: MyOpenGLProgram?

    var cubeVertexObject: MyOpenGLVertexObject?
    var quadVertexObject: MyOpenGLVertexObject?

    var msaaFramebuffer: MyOpenGLMSAAFramebuffer?
    var normalFramebuffer: MyOpenGLFramebuffer?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.msaaFramebuffer = MyOpenGLMSAAFramebuffer(width: 300, height: 200, multisample: true, multisampleNumber: 4)
        self.normalFramebuffer = MyOpenGLFramebuffer(width: 300, height: 200)
    }

    func prepareProgram() {
        self.cubeProgram = MyOpenGLUtils.createProgramWithName(name: "AntiAlias")
        self.quadProgram = MyOpenGLUtils.createProgramWithName(name: "FramebufferScreen")
    }

    func prepareVertices() {
        let cubeVertices: [GLfloat] = [
            // positions
            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,
            0.5,  0.5, -0.5,
            0.5,  0.5, -0.5,
            -0.5,  0.5, -0.5,
            -0.5, -0.5, -0.5,

            -0.5, -0.5,  0.5,
            0.5, -0.5,  0.5,
            0.5,  0.5,  0.5,
            0.5,  0.5,  0.5,
            -0.5,  0.5,  0.5,
            -0.5, -0.5,  0.5,

            -0.5,  0.5,  0.5,
            -0.5,  0.5, -0.5,
            -0.5, -0.5, -0.5,
            -0.5, -0.5, -0.5,
            -0.5, -0.5,  0.5,
            -0.5,  0.5,  0.5,

            0.5,  0.5,  0.5,
            0.5,  0.5, -0.5,
            0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,
            0.5, -0.5,  0.5,
            0.5,  0.5,  0.5,

            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,
            0.5, -0.5,  0.5,
            0.5, -0.5,  0.5,
            -0.5, -0.5,  0.5,
            -0.5, -0.5, -0.5,

            -0.5,  0.5, -0.5,
            0.5,  0.5, -0.5,
            0.5,  0.5,  0.5,
            0.5,  0.5,  0.5,
            -0.5,  0.5,  0.5,
            -0.5,  0.5, -0.5
        ]
        let quadVertices: [GLfloat] = [
            // positions   // texCoords
            -1.0,  1.0,  0.0, 1.0,
            -1.0, -1.0,  0.0, 0.0,
            1.0, -1.0,  1.0, 0.0,

            -1.0,  1.0,  0.0, 1.0,
            1.0, -1.0,  1.0, 0.0,
            1.0,  1.0,  1.0, 1.0
        ]

        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3])
        self.quadVertexObject = MyOpenGLVertexObject(vertices: quadVertices, alignment: [2, 2])
    }

    func render(_ bounds: NSRect) {
        _ = self.msaaFramebuffer?.draw {
            glEnable(GLenum(GL_DEPTH_TEST))
            glClearColor(0.1, 0.1, 0.1, 1.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
            self.cubeProgram?.useProgramWith {
                (program) in
                let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
                let view = self.camera?.viewMatrix
                let model = GLKMatrix4Identity

                program.setMat4(name: "projection", value: projection)
                program.setMat4(name: "view", value: view!)
                program.setMat4(name: "model", value: model)

                self.cubeVertexObject?.useVertexObjectWith {
                    (vertexObject) in
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }
            glDisable(GLenum(GL_DEPTH_TEST))
        }

        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), (self.msaaFramebuffer?.fbo)!)
        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), (self.normalFramebuffer?.fbo)!)
        glBlitFramebuffer(0, 0, GLint(self.msaaFramebuffer!.width), GLint(self.msaaFramebuffer!.height), 0, 0, GLint(self.normalFramebuffer!.width), GLint(self.normalFramebuffer!.height), GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_NEAREST))
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)

        self.quadProgram?.useProgramWith {
            (program) in
            program.setInt(name: "screenTexture", value: 0)
            glClearColor(1.0, 1.0, 1.0, 1.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            self.quadVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glActiveTexture(GLenum(GL_TEXTURE0))
                glBindTexture(GLenum(GL_TEXTURE_2D), (self.normalFramebuffer?.tex)!)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            }
        }
    }

    func dispose() {
        self.msaaFramebuffer = nil
        self.normalFramebuffer = nil
        self.cubeProgram = nil
        self.quadProgram = nil
        self.cubeVertexObject = nil
        self.quadVertexObject = nil
    }
}
