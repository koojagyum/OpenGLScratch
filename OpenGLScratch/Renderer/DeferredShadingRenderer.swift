//
//  DeferredShadingRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 03/09/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class DeferredShadingRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var geometryProgram: MyOpenGLProgram?
    var lightingProgram: MyOpenGLProgram?
    var lightBoxProgram: MyOpenGLProgram?

    var model: MyOpenGLModel?

    var gBuffer: MyOpenGLFramebuffer?

    var cubeVertexObject: MyOpenGLVertexObject?
    var quadVertexObject: MyOpenGLVertexObject?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.model = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/nanosuit/nanosuit.obj")
    }

    func prepareProgram() {
        self.geometryProgram = MyOpenGLUtils.createProgramWithName(name: "gBuffer")
        self.lightingProgram = MyOpenGLUtils.createProgramWithName(name: "DeferredShading")
        self.lightBoxProgram = MyOpenGLUtils.createProgramWithName(name: "Lightbox")
    }

    func prepareVertices() {
        let cubeVertices: [GLfloat] = [
            // back face
            -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 0.0, // bottom-left
            1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 1.0, // top-right
            1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 0.0, // bottom-right
            1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 1.0, // top-right
            -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 0.0, // bottom-left
            -1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 1.0, // top-left
            // front face
            -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 0.0, // bottom-left
            1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 0.0, // bottom-right
            1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 1.0, // top-right
            1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 1.0, // top-right
            -1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 1.0, // top-left
            -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 0.0, // bottom-left
            // left face
            -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 1.0, 0.0, // top-right
            -1.0,  1.0, -1.0, -1.0,  0.0,  0.0, 1.0, 1.0, // top-left
            -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0.0, 1.0, // bottom-left
            -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0.0, 1.0, // bottom-left
            -1.0, -1.0,  1.0, -1.0,  0.0,  0.0, 0.0, 0.0, // bottom-right
            -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 1.0, 0.0, // top-right
            // right face
            1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 1.0, 0.0, // top-left
            1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0.0, 1.0, // bottom-right
            1.0,  1.0, -1.0,  1.0,  0.0,  0.0, 1.0, 1.0, // top-right
            1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0.0, 1.0, // bottom-right
            1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 1.0, 0.0, // top-left
            1.0, -1.0,  1.0,  1.0,  0.0,  0.0, 0.0, 0.0, // bottom-left
            // bottom face
            -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0.0, 1.0, // top-right
            1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 1.0, 1.0, // top-left
            1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 1.0, 0.0, // bottom-left
            1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 1.0, 0.0, // bottom-left
            -1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 0.0, 0.0, // bottom-right
            -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0.0, 1.0, // top-right
            // top face
            -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0.0, 1.0, // top-left
            1.0,  1.0 , 1.0,  0.0,  1.0,  0.0, 1.0, 0.0, // bottom-right
            1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 1.0, 1.0, // top-right
            1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 1.0, 0.0, // bottom-right
            -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0.0, 1.0, // top-left
            -1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 0.0, 0.0  // bottom-left
        ]
        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3,3,2])

        let quadVertices: [Float] = [
            // positions // texture Coords
            -1.0,  1.0, 0.0, 0.0, 1.0,
            -1.0, -1.0, 0.0, 0.0, 0.0,
            1.0,  1.0, 0.0, 1.0, 1.0,
            1.0, -1.0, 0.0, 1.0, 0.0,
            ]
        self.quadVertexObject = MyOpenGLVertexObject(vertices: quadVertices, alignment: [3,2])
    }

    func render(_ bounds: NSRect) {

    }

    func dispose() {
        self.geometryProgram = nil
        self.lightingProgram = nil
        self.lightBoxProgram = nil
        self.model = nil
        self.gBuffer = nil
        self.cubeVertexObject = nil
        self.quadVertexObject = nil
    }




}
