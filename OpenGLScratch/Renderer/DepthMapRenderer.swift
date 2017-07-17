//
//  DepthMapRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 15/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class DepthMapRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var depthMapProgram: MyOpenGLProgram?
    var debugDepthQuadProgram: MyOpenGLProgram?

    var woodTexture: MyOpenGLTexture?

    var planeVertexObject: MyOpenGLVertexObject?
    var cubeVertexObject: MyOpenGLVertexObject?
    var quadVertexObject: MyOpenGLVertexObject?

    var depthMapFbo: MyOpenGLFramebuffer?

    func prepare() {
        self.prepareProgram()
        self.prepareTexture()
        self.prepareVertices()

        self.depthMapFbo = MyOpenGLFramebufferForDepthMap(width: 1024, height: 1024)
    }

    func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        let lightPos = GLKVector3Make(-2.0, +4.0, -1.0)
        let nearPlane: GLfloat = 1.0
        let farPlane: GLfloat = 7.5
        let lightProjection = GLKMatrix4MakeOrtho(-10.0, +10.0, -10.0, +10.0, nearPlane, farPlane)
        let lightView = GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
        let lightSpaceMatrix = lightProjection * lightView

        var depthMapTextureId: GLuint = 0

        self.depthMapProgram?.useProgramWith {
            (program) in
            program.setMat4(name: "lightSpaceMatrix", value: lightSpaceMatrix)

            depthMapTextureId = self.depthMapFbo!.draw {
                glDrawBuffer(GLenum(GL_NONE))
                glReadBuffer(GLenum(GL_NONE))

                glClear(GLbitfield(GL_DEPTH_BUFFER_BIT))
                // glClear(GLbitfield(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT))
                glActiveTexture(GLenum(GL_TEXTURE0))
                self.woodTexture?.useTextureWith {
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
        }

        self.debugDepthQuadProgram?.useProgramWith {
            (program) in
            glViewport(0, 0, GLsizei(bounds.width), GLsizei(bounds.height))
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

            program.setFloat(name: "near_plane", value: nearPlane)
            program.setFloat(name: "far_plane", value: farPlane)
            program.setInt(name: "depthMap", value: 0)

            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), depthMapTextureId)
            self.quadVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(vertexObject.count))
            }
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.depthMapProgram = nil
        self.debugDepthQuadProgram = nil
        self.woodTexture = nil
        self.planeVertexObject = nil
        self.depthMapFbo = nil
        self.cubeVertexObject = nil
        self.quadVertexObject = nil
    }

    func prepareProgram() {
        self.depthMapProgram = MyOpenGLUtils.createProgramWithName(name: "Depthmap")
        self.debugDepthQuadProgram = MyOpenGLUtils.createProgramWithName(name: "DebugDepthQuad")
    }

    func prepareTexture() {
        self.woodTexture = MyOpenGLTexture(imageName: "wood")
    }

    func prepareVertices() {
        let planeVertices: [GLfloat] = [
            // positions        // normals      // texcoords
            +25.0, -0.5, +25.0,  0.0, 1.0, 0.0,  25.0,  0.0,
            -25.0, -0.5, +25.0,  0.0, 1.0, 0.0,   0.0,  0.0,
            -25.0, -0.5, -25.0,  0.0, 1.0, 0.0,   0.0, 25.0,

            +25.0, -0.5,  25.0,  0.0, 1.0, 0.0,  25.0,  0.0,
            -25.0, -0.5, -25.0,  0.0, 1.0, 0.0,   0.0, 25.0,
            +25.0, -0.5, -25.0,  0.0, 1.0, 0.0,  25.0, 10.0
        ]
        self.planeVertexObject = MyOpenGLVertexObject(vertices: planeVertices, alignment: [3,3,2])

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

        let quadVertices: [GLfloat] = [
            // positions        // texture Coords
            -1.0,  1.0, 0.0, 0.0, 1.0,
            -1.0, -1.0, 0.0, 0.0, 0.0,
            1.0,  1.0, 0.0, 1.0, 1.0,
            1.0, -1.0, 0.0, 1.0, 0.0
        ]
        self.quadVertexObject = MyOpenGLVertexObject(vertices: quadVertices, alignment: [3,2])
    }


}
