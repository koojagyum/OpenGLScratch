//
//  GeometryShaderRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 29/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class GeometryShaderRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var houseProgram: MyOpenGLProgram?
    var houseVertexObject: MyOpenGLVertexObject?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
    }

    func prepareProgram() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "GeometryShader", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "GeometryShader", type: "fsh")
        let gshSource = MyOpenGLUtils.loadStringFromResource(name: "GeometryShader", type: "gsh")
        self.houseProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!, gshSource: gshSource)
    }

    func prepareVertices() {
        let houseVertices: [GLfloat] = [
            -0.5, +0.5, 1.0, 0.0, 0.0, // top-left
            +0.5, +0.5, 0.0, 1.0, 0.0, // top-right
            +0.5, -0.5, 0.0, 0.0, 1.0, // bottom-right
            -0.5, -0.5, 1.0, 1.0, 0.0  // bottom-left
        ]
        self.houseVertexObject = MyOpenGLVertexObject(vertices: houseVertices, alignment: [2, 3])
    }

    func render(_ bounds: NSRect) {
        self.houseProgram?.useProgramWith {
            (program) in
            self.houseVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertexObject.count))
            }
        }
    }

    func dispose() {
        self.houseProgram = nil
        self.houseVertexObject = nil
    }
}
