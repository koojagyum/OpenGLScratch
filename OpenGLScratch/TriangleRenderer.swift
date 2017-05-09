//
//  TriangleRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 22/03/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class TriangleRenderer: MyOpenGLRendererDelegate {
    var vao: GLuint = 0
    var vbo: GLuint = 0
    var shaderProgram: MyOpenGLProgram?

    func prepare() {
        let vshSource =
        "#version 330 core" + "\n" +
        "layout (location = 0) in vec3 position;" + "\n" +
        "void main()" + "\n" +
        "{" + "\n" +
        "gl_Position = vec4(position.x, position.y, position.z, 1.0);" + "\n" +
        "}" + "\n"

        let fshSource =
        "#version 330 core" + "\n" +
        "out vec4 color;" + "\n" +
        "void main()" + "\n" +
        "{" + "\n" +
        "color = vec4(1.0, 0.5, 0.2, 1.0);" + "\n" +
        "}" + "\n"

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource, fshSource: fshSource)
        self.prepareVertices()
    }
    
    func render() {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        if let program = self.shaderProgram, program.useProgram() {
            glBindVertexArray(self.vao)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
            glBindVertexArray(0)
        }
    }
    
    func dispose() {
        glDeleteVertexArrays(1, &self.vao)
        glDeleteBuffers(1, &self.vbo)
        self.shaderProgram = nil
    }
    
    func prepareVertices() {
        let vertices: [Float] = [
            -0.5, -0.5, +0.0,
            +0.5, -0.5, +0.0,
            +0.0, +0.5, +0.0
        ]

        glGenVertexArrays(1, &self.vao)
        glBindVertexArray(self.vao)

        glGenBuffers(1, &self.vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<GLfloat>.stride), nil)
        glEnableVertexAttribArray(0)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }
}
