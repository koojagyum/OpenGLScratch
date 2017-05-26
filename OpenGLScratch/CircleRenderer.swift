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
        let vshSource =
            "#version 330 core" + "\n" +
            "layout (location = 0) in vec3 position;" + "\n" +
            "layout (location = 1) in vec3 color;" + "\n" +
            "out vec3 ourColor;" + "\n" +
            "out vec3 ourPosition;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "gl_Position = vec4(position.x, position.y, position.z, 1.0);" + "\n" +
            "ourColor = color;" + "\n" +
            "float ratio = 3.0 / 2.0;" + "\n" +
            "ourPosition = vec3(position.x * ratio, position.y, position.z);" + "\n" +
            "}" + "\n"

        let fshSource =
            "#version 330 core" + "\n" +
            "in vec3 ourColor;" + "\n" +
            "in vec3 ourPosition;" + "\n" +
            "out vec4 color;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "float radius = 0.5;" + "\n" +
            "vec3 origin = vec3(0.0);" + "\n" +
            "float dist = distance(origin, ourPosition);" + "\n" +
            "float delta = 0.01;" + "\n" +
            "float alpha = smoothstep(dist-delta, dist, radius-delta);" + "\n" +
            "color = vec4(ourColor, alpha);" + "\n" +
            "}" + "\n"

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource, fshSource: fshSource)
        self.prepareVertices()
    }

    override func renderInProgram() {
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        glEnable(GLenum(GL_BLEND))
        super.renderInProgram()
        glDisable(GLenum(GL_BLEND))
    }
}
