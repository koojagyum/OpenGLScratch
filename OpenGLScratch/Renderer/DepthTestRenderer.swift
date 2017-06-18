//
//  DepthTestRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 12/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class DepthTestRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }
    var rotation: Float = 0.0

    var shaderProgram: MyOpenGLProgram?

    var cubeVao: GLuint = 0
    var cubeVbo: GLuint = 0
    var planeVao: GLuint = 0
    var planeVbo: GLuint = 0

    var texture1: MyOpenGLTexture?
    var texture2: MyOpenGLTexture?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTextures()
    }

    func prepareProgram() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "fsh")
        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
    }

    func prepareVertices() {
        let cubeVertices: [GLfloat] = [
            -0.5, -0.5, -0.5,  0.0, 0.0,
            0.5, -0.5, -0.5,  1.0, 0.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            -0.5,  0.5, -0.5,  0.0, 1.0,
            -0.5, -0.5, -0.5,  0.0, 0.0,

            -0.5, -0.5,  0.5,  0.0, 0.0,
            0.5, -0.5,  0.5,  1.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            -0.5,  0.5,  0.5,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0, 0.0,

            -0.5,  0.5,  0.5,  1.0, 0.0,
            -0.5,  0.5, -0.5,  1.0, 1.0,
            -0.5, -0.5, -0.5,  0.0, 1.0,
            -0.5, -0.5, -0.5,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0, 0.0,
            -0.5,  0.5,  0.5,  1.0, 0.0,

            0.5,  0.5,  0.5,  1.0, 0.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            0.5, -0.5, -0.5,  0.0, 1.0,
            0.5, -0.5, -0.5,  0.0, 1.0,
            0.5, -0.5,  0.5,  0.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 0.0,

            -0.5, -0.5, -0.5,  0.0, 1.0,
            0.5, -0.5, -0.5,  1.0, 1.0,
            0.5, -0.5,  0.5,  1.0, 0.0,
            0.5, -0.5,  0.5,  1.0, 0.0,
            -0.5, -0.5,  0.5,  0.0, 0.0,
            -0.5, -0.5, -0.5,  0.0, 1.0,

            -0.5,  0.5, -0.5,  0.0, 1.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 0.0,
            -0.5,  0.5,  0.5,  0.0, 0.0,
            -0.5,  0.5, -0.5,  0.0, 1.0
        ]
        let planeVertices: [GLfloat] = [
            // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
            5.0, -0.5,  5.0,  2.0, 0.0,
            -5.0, -0.5,  5.0,  0.0, 0.0,
            -5.0, -0.5, -5.0,  0.0, 2.0,

            5.0, -0.5,  5.0,  2.0, 0.0,
            -5.0, -0.5, -5.0,  0.0, 2.0,
            5.0, -0.5, -5.0,  2.0, 2.0
        ]

        glGenVertexArrays(1, &self.cubeVao)
        glGenVertexArrays(1, &self.planeVao)
        glGenBuffers(1, &self.cubeVbo)
        glGenBuffers(1, &self.planeVbo)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.cubeVbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * cubeVertices.count, cubeVertices, GLenum(GL_STATIC_DRAW))

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.planeVbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * planeVertices.count, planeVertices, GLenum(GL_STATIC_DRAW))

        glBindVertexArray(self.cubeVao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.cubeVbo)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * MemoryLayout<GLfloat>.stride), nil)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 3))
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glBindVertexArray(0)

        glBindVertexArray(self.planeVao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.planeVbo)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * MemoryLayout<GLfloat>.stride), nil)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(5 * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 3))
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glBindVertexArray(0)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }

    func prepareTextures() {
        self.texture1 = MyOpenGLTexture(imageName: "marble")
        self.texture2 = MyOpenGLTexture(imageName: "metal")
    }

    func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))
        // glDepthFunc(GLenum(GL_ALWAYS)); // always pass the depth test (same effect as glDisable(GL_DEPTH_TEST))

        if let program = self.shaderProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)

            // cubes
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            // glUniform1i(glGetUniformLocation(program.program, "texture1"), 0)
            glBindVertexArray(self.cubeVao)
            var cubeModel1 = GLKMatrix4Translate(GLKMatrix4Identity, -1.0, +0.0, -1.0)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &cubeModel1)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            var cubeModel2 = GLKMatrix4Translate(GLKMatrix4Identity, +2.0, +0.0, +2.0)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &cubeModel2)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)

            // plane
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            // glUniform1i(glGetUniformLocation(program.program, "texture1"), 0)
            glBindVertexArray(self.planeVao)
            var planeModel = GLKMatrix4Identity
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &planeModel)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)

            glBindVertexArray(0)
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.shaderProgram = nil
        self.texture1 = nil
        self.texture2 = nil
        glDeleteBuffers(1, &self.cubeVao)
        glDeleteBuffers(1, &self.planeVao)
        glDeleteBuffers(1, &self.cubeVbo)
        glDeleteBuffers(1, &self.planeVbo)
    }
}
