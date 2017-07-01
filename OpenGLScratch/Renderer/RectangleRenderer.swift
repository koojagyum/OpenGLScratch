//
//  RectangleRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 09/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class RectangleRenderer: TriangleRenderer {
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
        self.vertexObject = MyOpenGLVertexObject(vertices: vertices, alignment: [3, 3], indices: indices)
    }

    override func render(_ bounds: NSRect) {
        self.shaderProgram?.useProgramWith {
            _ in
            self.vertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawElements(GLenum(GL_TRIANGLES), GLsizei(vertexObject.count), GLenum(GL_UNSIGNED_INT), nil)
            }
        }
    }
}
