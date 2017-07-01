//
//  RectanglePerspectiveRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 21/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class RectanglePerspectiveRenderer: RectangleTextureRenderer {
    override func prepare() {
        self.shaderProgram = MyOpenGLUtils.createProgramWithNames(vshName: "RectanglePerspective", fshName: "RectanglePerspective")
        self.prepareVertices()
        self.prepareTextures()
    }

    override func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, +0.0, 0.0, 1.0,
            +0.5, -0.5, +0.0, 1.0, 1.0,
            +0.5, +0.5, +0.0, 1.0, 0.0,
            -0.5, +0.5, +0.0, 0.0, 0.0,
        ]
        let indices: [GLuint] = [
            0, 1, 2,
            0, 2, 3
        ]
        self.vertexObject = MyOpenGLVertexObject(vertices: vertices, alignment: [3,  2], indices: indices)
    }

    override func render(_ bounds: NSRect) {
        self.shaderProgram?.useProgramWith {
            (program) in
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture1"), 0)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture2"), 1)

            let model = GLKMatrix4MakeXRotation(Float(-55.0).radian)
            let view = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0)
            let projection = GLKMatrix4MakePerspective(Float(45.0).radian, (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)

            program.setMat4(name: "model", value: model)
            program.setMat4(name: "view", value: view)
            program.setMat4(name: "projection", value: projection)

            self.vertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawElements(GLenum(GL_TRIANGLES), GLsizei(vertexObject.count), GLenum(GL_UNSIGNED_INT), nil)
            }

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }
    }
}
