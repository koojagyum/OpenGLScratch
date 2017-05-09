//
//  RectangleRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 09/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class RectangleRenderer: TriangleRenderer {

    var ebo: GLuint = 0

    override func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, +0.0, 1.0, 0.0, 0.0,
            +0.5, -0.5, +0.0, 0.0, 1.0, 0.0,
            +0.5, +0.5, +0.0, 0.0, 0.0, 1.0,
            -0.5, +0.5, +0.0, 1.0, 1.0, 0.0,
        ]
        let indices: [GLuint] = [
            0, 1, 2,
            0, 2, 3
        ]

        glGenVertexArrays(1, &self.vao)
        glBindVertexArray(self.vao)

        glGenBuffers(1, &self.vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        glGenBuffers(1, &self.ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLuint>.stride * indices.count, indices, GLenum(GL_STATIC_DRAW))

        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), nil)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 3))
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }

    override func render() {
        if let program = self.shaderProgram, program.useProgram() {
            glBindVertexArray(self.vao)
            glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)
            glBindVertexArray(0)
        }
    }

    override func dispose() {
        super.dispose()
        glDeleteBuffers(1, &self.ebo)
    }
}
