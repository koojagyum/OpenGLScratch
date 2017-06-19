//
//  StencilOutlineRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 13/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class StencilOutlineRenderer: DepthTestRenderer {

    var shaderProgramBorder: MyOpenGLProgram?

    override func prepare() {
        super.prepare()

        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "vsh")
        let singleColorFshSource = MyOpenGLUtils.loadStringFromResource(name: "StencilTestSingleColor", type: "fsh")

        self.shaderProgramBorder = MyOpenGLProgram(vshSource: vshSource!, fshSource: singleColorFshSource!)
    }

    override func render(_ bounds: NSRect) {
        // configure global opengl state
        // -----------------------------
        glEnable(GLenum(GL_DEPTH_TEST));
        glDepthFunc(GLenum(GL_LESS));
        glEnable(GLenum(GL_STENCIL_TEST));
        glStencilFunc(GLenum(GL_NOTEQUAL), 1, 0xFF);
        glStencilOp(GLenum(GL_KEEP), GLenum(GL_KEEP), GLenum(GL_REPLACE));

        glClearColor(0.1, 0.1, 0.1, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)); // don't forget to clear the stencil buffer!

        if let program = self.shaderProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)

            // draw floor as normal, but don't write the floor to the stencil buffer, we only care about the containers. We set its mask to 0x00 to not write to the stencil buffer.
            glStencilMask(0x00);
            // plane
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            glBindVertexArray(self.planeVao)
            var planeModel = GLKMatrix4Identity
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &planeModel)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)

            // 1st. render pass, draw objects as normal, writing to the stencil buffer
            glStencilFunc(GLenum(GL_ALWAYS), 1, 0xFF);
            glStencilMask(0xFF);
            // cubes
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glBindVertexArray(self.cubeVao)
            var cubeModel1 = GLKMatrix4Translate(GLKMatrix4Identity, -1.0, +0.0, -1.0)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &cubeModel1)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            var cubeModel2 = GLKMatrix4Translate(GLKMatrix4Identity, +2.0, +0.0, +2.0)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &cubeModel2)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)

            glBindVertexArray(0)
        }

        if let program = self.shaderProgramBorder, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)

            // 2nd. render pass: now draw slightly scaled versions of the objects, this time disabling stencil writing.
            // Because the stencil buffer is now filled with several 1s. The parts of the buffer that are 1 are not drawn, thus only drawing
            // the objects' size differences, making it look like borders.
            glStencilFunc(GLenum(GL_NOTEQUAL), 1, 0xFF);
            glStencilMask(0x00);
            glDisable(GLenum(GL_DEPTH_TEST));

            let scale: Float = 1.1
            // cubes
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glBindVertexArray(self.cubeVao)
            var cubeModel1 = GLKMatrix4Scale(GLKMatrix4Translate(GLKMatrix4Identity, -1.0, +0.0, -1.0), scale, scale, scale)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &cubeModel1)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            var cubeModel2 = GLKMatrix4Scale(GLKMatrix4Translate(GLKMatrix4Identity, +2.0, +0.0, +2.0), scale, scale, scale)
            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &cubeModel2)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)

            glBindVertexArray(0)
            glStencilMask(0xFF);
            glEnable(GLenum(GL_DEPTH_TEST));
        }

        glDisable(GLenum(GL_DEPTH_TEST));
        glDisable(GLenum(GL_STENCIL_TEST));
    }
}
