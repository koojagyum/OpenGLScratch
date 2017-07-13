//
//  BlinnPhongRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 13/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class BlinnPhongRenderer: MyOpenGLRendererDelegate, MyOpenGLKeyConsumable {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var blinnPhongProgram: MyOpenGLProgram?
    var lampProgram: MyOpenGLProgram?

    var planeVertexObject: MyOpenGLVertexObject?
    var lampVertexObject: MyOpenGLVertexObject?

    var woodTexture: MyOpenGLTexture?

    var useBlinn = false

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTexture()
    }

    func prepareProgram() {
        self.blinnPhongProgram = MyOpenGLUtils.createProgramWithName(name: "BlinnPhong")
        self.lampProgram = MyOpenGLUtils.createProgramWithName(name: "Lamp")
    }
    
    func prepareVertices() {
        let planeVertices: [GLfloat] = [
            // positions        // normals      // texcoords
            10.0, -0.5,  10.0,  0.0, 1.0, 0.0,  10.0,  0.0,
            -10.0, -0.5,  10.0,  0.0, 1.0, 0.0,   0.0,  0.0,
            -10.0, -0.5, -10.0,  0.0, 1.0, 0.0,   0.0, 10.0,

            10.0, -0.5,  10.0,  0.0, 1.0, 0.0,  10.0,  0.0,
            -10.0, -0.5, -10.0,  0.0, 1.0, 0.0,   0.0, 10.0,
            10.0, -0.5, -10.0,  0.0, 1.0, 0.0,  10.0, 10.0
        ]
        let lampVertices: [GLfloat] = [
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
            0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
 
            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
            0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
 
            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
            -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
            0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
            0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
            0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
        ]

        self.planeVertexObject = MyOpenGLVertexObject(vertices: planeVertices, alignment: [3,3,2])
        self.lampVertexObject = MyOpenGLVertexObject(vertices: lampVertices, alignment: [3,3])
    }

    func prepareTexture() {
        self.woodTexture = MyOpenGLTexture(imageName: "wood")
    }

    func render(_ bounds: NSRect) {
        let lightPos = GLKVector3Make(0.0, 0.0, 0.0)
        let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
        let view = self.camera!.viewMatrix

        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        glEnable(GLenum(GL_DEPTH_TEST))

        self.blinnPhongProgram?.useProgramWith {
            (program) in
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)

            program.setVec3(name: "lightPos", value: lightPos)
            program.setVec3(name: "viewPos", value: self.camera!.position)

            program.setInt(name: "blinn", value: self.useBlinn ? 1 : 0)

            self.woodTexture?.useTextureWith {
                self.planeVertexObject?.useVertexObjectWith {
                    (vertexObject) in
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }
        }

        self.lampProgram?.useProgramWith {
            (program) in
            let model = GLKMatrix4TranslateWithVector3(GLKMatrix4MakeScale(0.2, 0.2, 0.2), lightPos)

            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)
            program.setMat4(name: "model", value: model)

            self.lampVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST));
    }

    func dispose() {
        self.blinnPhongProgram = nil
        self.lampProgram = nil
        self.planeVertexObject = nil
        self.lampVertexObject = nil
        self.woodTexture = nil
    }

    func processKeyDown(keyCode: UInt16) {
        if keyCode == 11 { // 'B'
            self.useBlinn = !self.useBlinn
        }
    }
}
