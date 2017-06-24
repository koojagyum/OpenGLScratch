//
//  MyOpenGLVertexObject.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 17/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLVertexObject {
    var vao: GLuint = 0
    var vbo: GLuint = 0

    let stride: Int
    let count: Int

    init(vertices: [GLfloat], alignment: [UInt]) {
        // Calc stride & count
        var sum = 0
        for part in alignment {
            sum = sum + Int(part)
        }
        self.stride = sum
        self.count = vertices.count / self.stride

        glGenVertexArrays(1, &self.vao)
        glGenBuffers(1, &self.vbo)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        glBindVertexArray(self.vao)
        for i in 0..<alignment.count {
            glVertexAttribPointer(GLuint(i), GLint(alignment[i]), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(self.stride * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(self.offsetOf(index: i, alignment: alignment) * MemoryLayout<GLfloat>.stride))
            glEnableVertexAttribArray(GLuint(i))
        }
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }

    func offsetOf(index: Int, alignment: [UInt]) -> Int {
        var offset: UInt = 0
        for i in 0..<index {
            offset = offset + alignment[i]
        }
        return Int(offset)
    }

    func useVertexObject() {
        glBindVertexArray(self.vao)
    }

    func useVertexObjectWith(block: () -> ()) {
        glBindVertexArray(self.vao)
        block()
        glBindVertexArray(0)
    }

    deinit {
        glDeleteBuffers(1, &self.vao)
        glDeleteBuffers(1, &self.vbo)
    }
}
