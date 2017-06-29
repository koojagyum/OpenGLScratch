//
//  WindowBlendRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 18/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class WindowBlendRenderer: DepthTestRenderer {
    var windowProgram: MyOpenGLProgram?
    var texture3: MyOpenGLTexture?
    var windowVertex: MyOpenGLVertexObject?

    override func prepareProgram() {
        super.prepareProgram()

        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "fsh")
        self.windowProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
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
        self.windowVertex = MyOpenGLVertexObject(vertices: transparentVertices, alignment: alignment)
    }

    override func prepareTextures() {
        super.prepareTextures()
        self.texture3 = MyOpenGLTexture(imageName: "blending_transparent_window")
    }

    override func render(_ bounds: NSRect) {
        super.render(bounds)

        let windows = [
            GLKVector3Make(-1.5, 0.0, -0.48),
            GLKVector3Make(-1.5, 0.0, +0.51),
            GLKVector3Make(+0.0, 0.0, +0.70),
            GLKVector3Make(-0.3, 0.0, -2.30),
            GLKVector3Make(+0.5, 0.0, -0.60),
        ]

        var distanceWindows: [Float : GLKVector3] = [:]
        for window in windows {
            let distance = GLKVector3Length((self.camera?.position)! - window)
            distanceWindows[distance] = window
        }
        let sortedWindows = distanceWindows.sorted(by: { return $0.0 > $1.0 } )

        if let program = self.windowProgram, program.useProgram() {
            glEnable(GLenum(GL_DEPTH_TEST))
            glEnable(GLenum(GL_BLEND));
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));

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

            self.windowVertex?.useVertexObjectWith {
                (vertexObject) in
                for window in sortedWindows {
                    var model = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, window.value)
                    MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }

            glDisable(GLenum(GL_BLEND))
            glDisable(GLenum(GL_DEPTH_TEST))
        }
    }

    override func dispose() {
        super.dispose()
        self.texture3 = nil
        self.windowVertex = nil
        self.windowProgram = nil
    }
}
