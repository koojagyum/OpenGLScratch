//
//  ShadowMappingRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 17/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class ShadowMappingRenderer: DepthMapRenderer {
    var shadowMappingProgram: MyOpenGLProgram?
    var lampProgram: MyOpenGLProgram?

    var lampVertexObject: MyOpenGLVertexObject?

    override func prepare() {
        super.prepare()
    }

    override func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        let nearPlane: GLfloat = 1.0
        let farPlane: GLfloat = 7.5
        let lightProjection = GLKMatrix4MakeOrtho(-10.0, +10.0, -10.0, +10.0, nearPlane, farPlane)
        let lightView = GLKMatrix4MakeLookAt(self.lightPos.x, self.lightPos.y, self.lightPos.z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
        let lightSpaceMatrix = lightProjection * lightView

        var depthMapTextureId: GLuint = 0

        self.depthMapProgram?.useProgramWith {
            (program) in
            program.setMat4(name: "lightSpaceMatrix", value: lightSpaceMatrix)

            depthMapTextureId = self.depthMapFbo!.draw {
                glDrawBuffer(GLenum(GL_NONE))
                glReadBuffer(GLenum(GL_NONE))

                glClear(GLbitfield(GL_DEPTH_BUFFER_BIT))
                glActiveTexture(GLenum(GL_TEXTURE0))
                self.woodTexture?.useTextureWith {
                    self.planeVertexObject?.useVertexObjectWith {
                        (vertexObject) in
                        program.setMat4(name: "model", value: GLKMatrix4Identity)
                        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                    }
                    self.drawScene(program: program)
                }
            }
        }

        self.shadowMappingProgram?.useProgramWith {
            (program) in
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = self.camera!.viewMatrix
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)

            program.setVec3(name: "viewPos", value: self.camera!.position)
            program.setVec3(name: "lightPos", value: self.lightPos)
            program.setMat4(name: "lightSpaceMatrix", value: lightSpaceMatrix)

            glActiveTexture(GLenum(GL_TEXTURE0))
            self.woodTexture?.useTextureWith {
                glActiveTexture(GLenum(GL_TEXTURE1))
                glBindTexture(GLenum(GL_TEXTURE_2D), depthMapTextureId)
                self.drawScene(program: program)
                glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            }
        }

        self.lampProgram?.useProgramWith {
            (program) in
            let model = GLKMatrix4TranslateWithVector3(GLKMatrix4MakeScale(0.2, 0.2, 0.2), self.lightPos)
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = self.camera!.viewMatrix

            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)
            program.setMat4(name: "model", value: model)

            self.lampVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    override func dispose() {
        super.dispose()
        self.shadowMappingProgram = nil
        self.lampProgram = nil
    }

    override func prepareProgram() {
        super.prepareProgram()
        self.shadowMappingProgram = MyOpenGLUtils.createProgramWithName(name: "ShadowMapping")
        self.shadowMappingProgram?.useProgramWith {
            (program) in
            program.setInt(name: "diffuseTexture", value: 0)
            program.setInt(name: "shadowMap", value: 1)
        }
        self.lampProgram = MyOpenGLUtils.createProgramWithName(name: "Lamp")
    }

    override func prepareVertices() {
        super.prepareVertices()

        let lampVertices: [GLfloat] = [
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
            0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,

            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
            0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,

            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
            -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
            0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
            0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
            0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
        ]
        self.lampVertexObject = MyOpenGLVertexObject(vertices: lampVertices, alignment: [3,3])
    }

    func drawScene(program: MyOpenGLProgram) {
        self.planeVertexObject?.useVertexObjectWith {
            (vertexObject) in
            program.setMat4(name: "model", value: GLKMatrix4Identity)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
        }

        self.cubeVertexObject?.useVertexObjectWith {
            (vertexObject) in
            let primitiveCount = vertexObject.count

            program.setMat4(name: "model", value: GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, 1.5, 0.0), 0.5, 0.5, 0.5))
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(primitiveCount))

            program.setMat4(name: "model", value: GLKMatrix4Scale(GLKMatrix4MakeTranslation(2.0, 0.0, 1.0), 0.5, 0.5, 0.5))
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(primitiveCount))

            program.setMat4(name: "model", value: GLKMatrix4Scale(GLKMatrix4RotateWithVector3(GLKMatrix4MakeTranslation(-1.0, 0.0, 2.0), Float(60.0).radian, GLKVector3Make(1.0, 0.0, 1.0)), 0.25, 0.25, 0.25))
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(primitiveCount))
        }
    }
}
