//
//  SpinningLampRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 28/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class SpinningLampRenderer: LightingAndLampRenderer {
    override var renderInterval: Double {
        return 1.0 / 60.0
    }
    var rotation: Float = 0.0

    override func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))

        self.rotation += 1.0
        let radius: GLfloat = 3.0
        let lightX: GLfloat = sinf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightY: GLfloat = 0.0
        let lightZ: GLfloat = cosf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightPos = GLKVector3Make(lightX, lightY, lightZ)

        if let program = self.lightingProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")
            let lightPosLoc = glGetUniformLocation(program.program, "lightPos")
            let objectColorLoc = glGetUniformLocation(program.program, "objectColor")
            let lightColorLoc = glGetUniformLocation(program.program, "lightColor")
            let viewPosLoc = glGetUniformLocation(program.program, "viewPos")

            glUniform3f(objectColorLoc, 1.0, 0.5, 0.31)
            glUniform3f(lightColorLoc, 1.0, 1.0, 1.0)
            glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z)
            glUniform3f(viewPosLoc, (camera?.position.x)!, (camera?.position.y)!, (camera?.position.z)!)
            print("camera: \((camera?.position.x)!), \((camera?.position.y)!), \((camera?.position.z)!)")

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            glBindVertexArray(self.containerVao)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            glBindVertexArray(0)
        }

        if let program = self.lampProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

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
        glDisable(GLenum(GL_DEPTH_TEST));
    }
}
