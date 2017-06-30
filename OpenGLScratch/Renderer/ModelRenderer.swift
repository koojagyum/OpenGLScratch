//
//  ModelRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 05/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class ModelRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 1.0 / 60.0
    }
    var rotation: Float = 0.0

    var modelProgram: MyOpenGLProgram?
    var lampProgram: MyOpenGLProgram?
    var model: MyOpenGLModel?

    var lightVertexObject: MyOpenGLVertexObject?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.model = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/nanosuit/nanosuit.obj")
    }

    func render(_ bounds: NSRect) {
        let radius: GLfloat = 3.0
        let lightX: GLfloat = sinf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightY: GLfloat = 0.0
        let lightZ: GLfloat = cosf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightPos = GLKVector3Make(lightX, lightY, lightZ)

        glClearColor(0.1, 0.1, 0.2, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        self.modelProgram?.useProgramWith {
            (program) in
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)

            var model = GLKMatrix4Identity
            model = GLKMatrix4Translate(model, 0.0, -1.75, 0.0)
            model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2)

            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "model", value: model)
            program.setMat4(name: "view", value: (self.camera?.viewMatrix)!)

            let ambientColor = GLKVector3Make(0.2, 0.2, 0.2)
            let diffuseColor = GLKVector3Make(0.5, 0.5, 0.5)
            let lightColor = GLKVector3Make(1.0, 1.0, 1.0)

            program.setVec3(name: "light.ambient", value: ambientColor)
            program.setVec3(name: "light.diffuse", value: diffuseColor)
            program.setVec3(name: "light.specular", value: lightColor)
            program.setVec3(name: "light.position", value: lightPos)

            if let m = self.model {
                m.draw(program: program)
            }
        }

        self.lampProgram?.useProgramWith {
            (program) in
            var model = GLKMatrix4Identity
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)

            model = GLKMatrix4TranslateWithVector3(model, lightPos)
            model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2) // Make it smaller cube

            program.setMat4(name: "model", value: model)
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: (self.camera?.viewMatrix)!)

            self.lightVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST))
        self.rotation += 1.0
    }

    func prepareProgram() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "BasicModel", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "BasicModel", type: "fsh")
        self.modelProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)

        let vshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "vsh")
        let fshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "fsh")
        self.lampProgram = MyOpenGLProgram(vshSource: vshLamp!, fshSource: fshLamp!)
    }

    func prepareVertices() {
        let vertices: [GLfloat] = [
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

        self.lightVertexObject = MyOpenGLVertexObject(vertices: vertices, alignment: [3, 3])
    }

    func dispose() {
        self.modelProgram = nil
        self.lampProgram = nil
        self.model = nil
        self.lightVertexObject = nil
    }
}
