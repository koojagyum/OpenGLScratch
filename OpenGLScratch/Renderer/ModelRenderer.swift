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

    var shaderProgram: MyOpenGLProgram?
    var lampProgram: MyOpenGLProgram?
    var model: MyOpenGLModel?

    var lightVao: GLuint = 0
    var vbo: GLuint = 0

    func prepare() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "BasicModel", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "BasicModel", type: "fsh")

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
        self.model = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/nanosuit/nanosuit.obj")
        // self.model = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/Pikachu/Pikachu.obj")

        let vshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "vsh")
        let fshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "fsh")
        self.lampProgram = MyOpenGLProgram(vshSource: vshLamp!, fshSource: fshLamp!)

        self.prepareVertices()
    }

    func render(_ bounds: NSRect) {
        let radius: GLfloat = 3.0
        let lightX: GLfloat = sinf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightY: GLfloat = 0.0
        let lightZ: GLfloat = cosf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightPos = GLKVector3Make(lightX, lightY, lightZ)

        glClearColor(0.3, 0.3, 0.3, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        if let m = self.model, let program = self.shaderProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            var model = GLKMatrix4Identity
            model = GLKMatrix4Translate(model, 0.0, -1.75, 0.0)
            model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)

            let ambientColor = GLKVector3Make(0.2, 0.2, 0.2)
            let diffuseColor = GLKVector3Make(0.5, 0.5, 0.5)
            let lightColor = GLKVector3Make(1.0, 1.0, 1.0)

            let lightAmbientLoc  = glGetUniformLocation(program.program, "light.ambient");
            let lightDiffuseLoc  = glGetUniformLocation(program.program, "light.diffuse");
            let lightSpecularLoc = glGetUniformLocation(program.program, "light.specular");
            let lightPosLoc = glGetUniformLocation(program.program, "light.position");

            glUniform3f(lightAmbientLoc, ambientColor.x, ambientColor.y, ambientColor.z);
            glUniform3f(lightDiffuseLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z);
            glUniform3f(lightSpecularLoc, lightColor.x, lightColor.y, lightColor.z);

            glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z)

            m.draw(program: program)
        }

        if let program = self.lampProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)

            model = GLKMatrix4TranslateWithVector3(model, lightPos)
            model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2) // Make it smaller cube

            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            glBindVertexArray(self.lightVao)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            glBindVertexArray(0)
        }

        glDisable(GLenum(GL_DEPTH_TEST))
        self.rotation += 1.0
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

        glGenVertexArrays(1, &self.lightVao)

        glGenBuffers(1, &self.vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        glBindVertexArray(self.lightVao)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), nil)
        glEnableVertexAttribArray(0)
        glBindVertexArray(0)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }

    func dispose() {
        self.shaderProgram = nil
        glDeleteBuffers(1, &self.lightVao)
        glDeleteBuffers(1, &self.vbo)
    }
}
