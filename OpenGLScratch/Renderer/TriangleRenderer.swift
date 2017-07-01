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

    var vertexObject: MyOpenGLVertexObject?
    var shaderProgram: MyOpenGLProgram?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
    }

    func render(_ bounds: NSRect) {
        self.shaderProgram?.useProgramWith {
            _ in
            self.vertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
        }
    }

    func dispose() {
        self.shaderProgram = nil
        self.vertexObject = nil
    }

    func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, +0.0, 1.0, 0.0, 0.0,
            +0.5, -0.5, +0.0, 0.0, 1.0, 0.0,
            +0.0, +0.5, +0.0, 0.0, 0.0, 1.0,
        ]
        self.vertexObject = MyOpenGLVertexObject(vertices: vertices, alignment: [3, 3])
    }

    func prepareProgram() {
        self.shaderProgram = MyOpenGLUtils.createProgramWithNames(vshName: "Triangle", fshName: "Triangle")
    }
}
