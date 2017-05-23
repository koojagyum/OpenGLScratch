//
//  RectangleTextureRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 13/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import OpenGL.GL3

class RectangleTextureRenderer: RectangleRenderer {
    var texture1: MyOpenGLTexture?
    var texture2: MyOpenGLTexture?

    override func prepare() {
        let vshSource =
            "#version 330 core" + "\n" +
            "layout (location = 0) in vec3 position;" + "\n" +
            "layout (location = 1) in vec3 color;" + "\n" +
            "layout (location = 2) in vec2 texCoord;" + "\n" +
            "out vec3 ourColor;" + "\n" +
            "out vec2 TexCoord;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "gl_Position = vec4(position.x, position.y, position.z, 1.0);" + "\n" +
            "ourColor = color;" + "\n" +
            "TexCoord = texCoord;" + "\n" +
            "}" + "\n"

        let fshSource =
            "#version 330 core" + "\n" +
            "in vec3 ourColor;" + "\n" +
            "in vec2 TexCoord;" + "\n" +
            "out vec4 color;" + "\n" +
            "uniform sampler2D ourTexture1;" + "\n" +
            "uniform sampler2D ourTexture2;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "color = mix(texture(ourTexture1, TexCoord), texture(ourTexture2, TexCoord), 0.2);" + "\n" +
            "}" + "\n"

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource, fshSource: fshSource)
        self.prepareVertices()
        self.prepareTextures()
    }

    override func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, +0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
            +0.5, -0.5, +0.0, 0.0, 1.0, 0.0, 1.0, 1.0,
            +0.5, +0.5, +0.0, 0.0, 0.0, 1.0, 1.0, 0.0,
            -0.5, +0.5, +0.0, 1.0, 1.0, 0.0, 0.0, 0.0,
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

        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(8 * MemoryLayout<GLfloat>.stride), nil)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(8 * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 3))
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(8 * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 6))
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glEnableVertexAttribArray(2)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }

    override func render(_ bounds: NSRect) {
        if let program = self.shaderProgram, program.useProgram() {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture1"), 0)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture2"), 1)

            glBindVertexArray(self.vao)
            glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)
            glBindVertexArray(0)

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }
    }

    override func dispose() {
        super.dispose()
        self.texture1 = nil
        self.texture2 = nil
    }

    func prepareTextures() {
        self.texture1 = MyOpenGLTexture(imageName: "container")
        self.texture2 = MyOpenGLTexture(imageName: "awesomeface")
    }
}
