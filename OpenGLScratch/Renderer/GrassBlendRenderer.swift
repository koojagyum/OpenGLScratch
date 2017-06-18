//
//  GrassBlendRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 17/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class GrassBlendRenderer: DepthTestRenderer {
    var vegetationProgram: MyOpenGLProgram?
    var texture3: MyOpenGLTexture?
    var transparentVertex: MyOpenGLVertexObject?

    override func render(_ bounds: NSRect) {
        super.render(bounds)

        let vegetations = [
            GLKVector3Make(-1.5, 0.0, -0.48),
            GLKVector3Make(-1.5, 0.0, +0.51),
            GLKVector3Make(+0.0, 0.0, +0.70),
            GLKVector3Make(-0.3, 0.0, -2.30),
            GLKVector3Make(+0.5, 0.0, -0.60),
        ]

        if let program = self.vegetationProgram, program.useProgram() {
            glEnable(GLenum(GL_DEPTH_TEST))

            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)

            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture3?.textureId)!)

            self.transparentVertex?.useVertexObject()
            for vegetation in vegetations {
                var model = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, vegetation)
                MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.transparentVertex!.count))
            }
            glBindVertexArray(0)

            glDisable(GLenum(GL_DEPTH_TEST))
        }
    }

    override func prepareVertices() {
        super.prepareVertices()

        let transparentVertices: [GLfloat] = [
            // positions      // texture Coords (swapped y coordinates because texture is flipped upside down)
            0.0,  0.5,  0.0,  0.0,  0.0,
            0.0, -0.5,  0.0,  0.0,  1.0,
            1.0, -0.5,  0.0,  1.0,  1.0,

            0.0,  0.5,  0.0,  0.0,  0.0,
            1.0, -0.5,  0.0,  1.0,  1.0,
            1.0,  0.5,  0.0,  1.0,  0.0
        ]
        let alignment: [UInt] = [3, 2]
        self.transparentVertex = MyOpenGLVertexObject(vertices: transparentVertices, alignment: alignment)
    }

    override func prepareTextures() {
        super.prepareTextures()
        self.texture3 = MyOpenGLTexture(imageName: "grass")
    }

    override func prepareProgram() {
        super.prepareProgram()

        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "Blending", type: "fsh")
        self.vegetationProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
    }

    override func dispose() {
        super.dispose()
        self.texture3 = nil
        self.transparentVertex = nil
        self.vegetationProgram = nil
    }
}
