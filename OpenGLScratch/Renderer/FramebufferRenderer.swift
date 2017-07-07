//
//  FramebufferRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 21/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class FramebufferRenderer: DepthTestRenderer {

    var screenProgram: MyOpenGLProgram?
    var quadVertex: MyOpenGLVertexObject?
    var framebuffer: MyOpenGLFramebuffer?

    override func prepareProgram() {
        super.prepareProgram()

        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "FramebufferScreen", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "FramebufferScreen", type: "fsh")
        self.screenProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
    }

    override func prepareVertices() {
        super.prepareVertices()

        // vertex attributes for a quad that fills the entire screen in Normalized Device Coordinates.
        let quadVertices: [Float] = [
            // positions   // texCoords
            -1.0,  1.0,  0.0, 1.0,
            -1.0, -1.0,  0.0, 0.0,
            1.0, -1.0,  1.0, 0.0,

            -1.0,  1.0,  0.0, 1.0,
            1.0, -1.0,  1.0, 0.0,
            1.0,  1.0,  1.0, 1.0
        ]
        let alignment: [UInt] = [2, 2]
        self.quadVertex = MyOpenGLVertexObject(vertices: quadVertices, alignment: alignment)
    }

    override func prepareTextures() {
        super.prepareTextures()
        self.texture1 = MyOpenGLTexture(imageName: "container")
    }

    override func prepare() {
        super.prepare()
        self.framebuffer = MyOpenGLFramebuffer(width: 300, height: 200)
    }

    override func render(_ bounds: NSRect) {
        let tex = self.framebuffer?.draw {
            glEnable(GLenum(GL_DEPTH_TEST))
            glClearColor(0.1, 0.1, 0.1, 1.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
            super.render(bounds)
            glDisable(GLenum(GL_DEPTH_TEST))
        }

        self.screenProgram?.useProgramWith {
            (program) in
            program.setInt(name: "screenTexture", value: 0)
            glClearColor(1.0, 1.0, 1.0, 1.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            self.quadVertex?.useVertexObjectWith {_ in
                glBindTexture(GLenum(GL_TEXTURE_2D), tex!)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
            }
        }
    }

    override func dispose() {
        super.dispose()
        screenProgram = nil
        quadVertex = nil
        framebuffer = nil
    }
}
