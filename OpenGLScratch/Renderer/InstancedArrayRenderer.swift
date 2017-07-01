//
//  InstancedArrayRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 01/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class InstancedArrayRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var quadProgram: MyOpenGLProgram?
    var quadVertexObject: MyOpenGLVertexObject?

    var instanceVbo: GLuint = 0

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
    }

    func prepareProgram() {
        self.quadProgram = MyOpenGLUtils.createProgramWithNames(vshName: "InstancedArray", fshName: "InstancedArray")
    }

    func prepareVertices() {
        let quadVertices: [GLfloat] = [
            // positions     // colors
            -0.05, +0.05,  1.0, 0.0, 0.0,
            +0.05, -0.05,  0.0, 1.0, 0.0,
            -0.05, -0.05,  0.0, 0.0, 1.0,

            -0.05, +0.05,  1.0, 0.0, 0.0,
            +0.05, -0.05,  0.0, 1.0, 0.0,
            +0.05, +0.05,  0.0, 1.0, 1.0
        ]

        self.quadVertexObject = MyOpenGLVertexObject(vertices: quadVertices, alignment: [2, 3])

        var translations = [GLKVector2]()
        for y in stride(from: -0.9, to: +0.91, by: 0.2) {
            for x in stride(from: -0.9, to: +0.91, by: 0.2) {
                translations.append(GLKVector2Make(Float(x), Float(y)))
            }
        }

        glGenBuffers(1, &self.instanceVbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.instanceVbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLKVector2>.stride * translations.count, translations, GLenum(GL_STATIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

        self.quadVertexObject?.useVertexObjectWith {
            (vertexObject) in
            let attributeIndex = GLuint(vertexObject.attributeCount)
            glEnableVertexAttribArray(attributeIndex)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.instanceVbo)
            glVertexAttribPointer(attributeIndex, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 2), nil)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            glVertexAttribDivisor(attributeIndex, 1) // tell OpenGL this is an instanced vertex attribute
        }
    }

    func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        self.quadProgram?.useProgramWith {
            (program) in
            self.quadVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArraysInstanced(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count), 100)
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.quadProgram = nil
        self.quadVertexObject = nil
        glDeleteBuffers(1, &self.instanceVbo)
    }
}
