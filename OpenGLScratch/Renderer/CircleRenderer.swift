//
//  CircleRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 26/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class CircleRenderer: RectangleRenderer {

    override func prepareProgram() {
        self.shaderProgram = MyOpenGLUtils.createProgramWithNames(vshName: "Circle", fshName: "Circle")
    }

    override func render(_ bounds: NSRect) {
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        glEnable(GLenum(GL_BLEND))
        super.render(bounds)
        glDisable(GLenum(GL_BLEND))
    }
}
