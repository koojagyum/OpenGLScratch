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
        return 0.0
    }

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

            m.draw(program: program)
            glDisable(GLenum(GL_DEPTH_TEST))
        }
    }

    func dispose() {
        self.shaderProgram = nil
    }
}
