//
//  NCubesWithCameraRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 23/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class NCubesWithCameraRenderer: CubeRenderer {
    override var renderInterval: Double {
        return 1.0 / 60.0
    }

    override func render(_ bounds: NSRect) {
        if let program = self.shaderProgram, program.useProgram() {
            glEnable(GLenum(GL_DEPTH_TEST))

            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture1"), 0)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture2"), 1)

            glBindVertexArray(self.vao)

            self.rotation += 1.0

            if var view = self.camera?.viewMatrix {
                self.uniformMatrix4fv(self.viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            self.uniformMatrix4fv(self.projLoc, 1, GLboolean(GL_FALSE), &projection)

            let cubePositions: [GLKVector3] = [
                GLKVector3Make(+0.0, +0.0, +0.0),
                GLKVector3Make(+2.0, +5.0, -15.0),
                GLKVector3Make(-1.5, -2.2, -2.5),
                GLKVector3Make(-3.8, -2.0, -12.3),
                GLKVector3Make(+2.4, -0.4, -3.5),
                GLKVector3Make(-1.7, +3.0, -7.5),
                GLKVector3Make(+1.3, -2.0, -2.5),
                GLKVector3Make(+1.5, +2.0, -2.5),
                GLKVector3Make(+1.5, +0.2, -1.5),
                GLKVector3Make(-1.3, +1.0, -1.5),
            ]

            for i in 0...9 {
                let angle: GLfloat = 20.0 * Float(i)
                var model = GLKMatrix4Identity
                model = GLKMatrix4TranslateWithVector3(model, cubePositions[i])
                model = GLKMatrix4RotateWithVector3(model, MyOpenGLUtils.DEGREE2RADIAN(angle), GLKVector3Make(1.0, 0.3, 0.5))
                model = GLKMatrix4RotateWithVector3(model, MyOpenGLUtils.DEGREE2RADIAN(self.rotation), GLKVector3Make(0.5, 1.0, 0.0))
                self.uniformMatrix4fv(self.modelLoc, 1, GLboolean(GL_FALSE), &model)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            }

            glBindVertexArray(0)

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)

            glDisable(GLenum(GL_DEPTH_TEST));
        }
    }
}
