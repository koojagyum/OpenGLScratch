//
//  NCubesRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 21/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class NCubesRenderer: CubeRenderer {
    override var renderInterval: Double {
        return 1.0 / 60.0
    }

    override func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))

        self.shaderProgram?.useProgramWith {
            (program) in
            let view = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0)
            let projection = GLKMatrix4MakePerspective((Float(45.0)).radian, (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)

            program.setMat4(name: "view", value: view)
            program.setMat4(name: "projection", value: projection)

            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture1"), 0)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture2"), 1)

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

            self.vertexObject?.useVertexObjectWith {
                (vertexObject) in
                for i in 0...9 {
                    let angle: GLfloat = 20.0 * Float(i)
                    var model = GLKMatrix4Identity
                    model = GLKMatrix4TranslateWithVector3(model, cubePositions[i])
                    model = GLKMatrix4RotateWithVector3(model, angle.radian, GLKVector3Make(1.0, 0.3, 0.5))
                    model = GLKMatrix4RotateWithVector3(model, self.rotation.radian, GLKVector3Make(0.5, 1.0, 0.0))
                    program.setMat4(name: "model", value: model)
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }

        self.rotation += 1.0
        glDisable(GLenum(GL_DEPTH_TEST));
    }
}
