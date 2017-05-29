//
//  TriangleRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 22/03/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import OpenGL.GL3

class TriangleRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var vao: GLuint = 0
    var vbo: GLuint = 0
    var shaderProgram: MyOpenGLProgram?

    func prepare() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "Triangle", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "Triangle", type: "fsh")

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
        self.prepareVertices()
    }

    func render(_ bounds: NSRect) {
        if let program = self.shaderProgram, program.useProgram() {
            self.renderInProgram()
        }
    }

    internal func renderInProgram() {
        glBindVertexArray(self.vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        glBindVertexArray(0)
    }

    func dispose() {
        glDeleteVertexArrays(1, &self.vao)
        glDeleteBuffers(1, &self.vbo)
        self.shaderProgram = nil
    }

    func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, +0.0, 1.0, 0.0, 0.0,
            +0.5, -0.5, +0.0, 0.0, 1.0, 0.0,
            +0.0, +0.5, +0.0, 0.0, 0.0, 1.0,
        ]

        glGenVertexArrays(1, &self.vao)
        glBindVertexArray(self.vao)

        glGenBuffers(1, &self.vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), nil)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 3))
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }
}