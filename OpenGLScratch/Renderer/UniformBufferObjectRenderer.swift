//
//  UniformBufferObjectRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 29/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class UniformBufferObjectRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }
    var rotation: Float = 0.0

    var redProgrem: MyOpenGLProgram?
    var greenProgrem: MyOpenGLProgram?
    var blueProgrem: MyOpenGLProgram?
    var yellowProgrem: MyOpenGLProgram?

    var cubeVertexObject: MyOpenGLVertexObject?

    var uboMatrices: GLuint = 0

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()

        glGenBuffers(1, &self.uboMatrices)
        glBindBuffer(GLenum(GL_UNIFORM_BUFFER), self.uboMatrices)
        glBufferData(GLenum(GL_UNIFORM_BUFFER), 2 * MemoryLayout<GLKMatrix4>.stride, nil, GLenum(GL_STATIC_DRAW))
        glBindBuffer(GLenum(GL_UNIFORM_BUFFER), 0)
        glBindBufferRange(GLenum(GL_UNIFORM_BUFFER), 0, self.uboMatrices, 0, 2 * MemoryLayout<GLKMatrix4>.stride)

        let indexRed = glGetUniformBlockIndex((self.redProgrem?.program)!, "Matrices")
        let indexGreen = glGetUniformBlockIndex((self.greenProgrem?.program)!, "Matrices")
        let indexBlue = glGetUniformBlockIndex((self.blueProgrem?.program)!, "Matrices")
        let indexYellow = glGetUniformBlockIndex((self.yellowProgrem?.program)!, "Matrices")

        glUniformBlockBinding((self.redProgrem?.program)!, indexRed, 0)
        glUniformBlockBinding((self.greenProgrem?.program)!, indexGreen, 0)
        glUniformBlockBinding((self.blueProgrem?.program)!, indexBlue, 0)
        glUniformBlockBinding((self.yellowProgrem?.program)!, indexYellow, 0)
    }

    func prepareProgram() {
        self.redProgrem = createProgramWithNames(vshName: "UniformBufferObject", fshName: "Red")
        self.greenProgrem = createProgramWithNames(vshName: "UniformBufferObject", fshName: "Green")
        self.blueProgrem = createProgramWithNames(vshName: "UniformBufferObject", fshName: "Blue")
        self.yellowProgrem = createProgramWithNames(vshName: "UniformBufferObject", fshName: "Yellow")
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
            -0.5,  0.5, -0.5,
        ]

        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3])
    }

    func createProgramWithNames(vshName: String, fshName: String) -> MyOpenGLProgram? {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: vshName, type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: fshName, type: "fsh")
        return MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
    }

    func render(_ bounds: NSRect) {
        var view = self.camera?.viewMatrix
        var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

        glBindBuffer(GLenum(GL_UNIFORM_BUFFER), self.uboMatrices)
        glBufferSubData(GLenum(GL_UNIFORM_BUFFER), 0, MemoryLayout<GLKMatrix4>.stride, &projection)
        glBufferSubData(GLenum(GL_UNIFORM_BUFFER), MemoryLayout<GLKMatrix4>.stride, MemoryLayout<GLKMatrix4>.stride, &view)
        glBindBuffer(GLenum(GL_UNIFORM_BUFFER), 0)

        let drawingBlock: (MyOpenGLProgram, Float, Float) -> () = {
            (program, x, y) in
            self.cubeVertexObject?.useVertexObjectWith {
                (vertexObject) in
                let model = GLKMatrix4MakeTranslation(x, y, +0.00)
                program.setMat4(name: "model", value: model)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
        }

        self.redProgrem?.useProgramWith { drawingBlock($0, -0.75, +0.75) }
        self.greenProgrem?.useProgramWith { drawingBlock($0, +0.75, +0.75) }
        self.blueProgrem?.useProgramWith { drawingBlock($0, -0.75, -0.75) }
        self.yellowProgrem?.useProgramWith { drawingBlock($0, +0.75, -0.75) }
    }

    func dispose() {
        self.redProgrem = nil
        self.greenProgrem = nil
        self.blueProgrem = nil
        self.yellowProgrem = nil
        self.cubeVertexObject = nil
        glDeleteBuffers(1, &self.uboMatrices)
    }
}
