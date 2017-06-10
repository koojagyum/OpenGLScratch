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
        return 1.0/60.0
    }
    var rotation: Float = 0.0

    var shaderProgram: MyOpenGLProgram?
    var model: MyOpenGLModel?

    var modelLoc: GLint = 0
    var viewLoc: GLint = 0
    var projLoc: GLint = 0

    func prepare() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "BasicModel", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "BasicModel", type: "fsh")

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
        self.modelLoc = glGetUniformLocation((self.shaderProgram?.program)!, "model")
        self.viewLoc = glGetUniformLocation((self.shaderProgram?.program)!, "view")
        self.projLoc = glGetUniformLocation((self.shaderProgram?.program)!, "projection")
        self.model = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/nanosuit/nanosuit.obj")
    }

    func render(_ bounds: NSRect) {
        if let m = self.model, let program = self.shaderProgram, program.useProgram() {
            glEnable(GLenum(GL_DEPTH_TEST))
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(self.viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(self.projLoc, 1, GLboolean(GL_FALSE), &projection)
            var model = GLKMatrix4Identity
            model = GLKMatrix4Translate(model, 0.0, -1.75, 0.0)
            model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2)
            MyOpenGLUtils.uniformMatrix4fv(self.modelLoc, 1, GLboolean(GL_FALSE), &model)

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

            let radius: GLfloat = 3.0
            let lightX: GLfloat = sinf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
            let lightY: GLfloat = 0.0
            let lightZ: GLfloat = cosf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
            let lightPos = GLKVector3Make(lightX, lightY, lightZ)

            glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z)

            m.draw(program: program)
            glDisable(GLenum(GL_DEPTH_TEST))
        }
        self.rotation += 1.0
    }

    func dispose() {
        self.shaderProgram = nil
    }
}
