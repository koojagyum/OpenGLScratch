//
//  CircleRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 26/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class CircleRenderer: RectangleRenderer {

    override func prepare() {
        let vshSource = MyOpenGLUtils.loadStringFromResource(name: "Circle", type: "vsh")
        let fshSource = MyOpenGLUtils.loadStringFromResource(name: "Circle", type: "fsh")

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource!, fshSource: fshSource!)
        self.prepareVertices()
    }

    override func renderInProgram() {
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        glEnable(GLenum(GL_BLEND))
        super.renderInProgram()
        glDisable(GLenum(GL_BLEND))
    }
}
