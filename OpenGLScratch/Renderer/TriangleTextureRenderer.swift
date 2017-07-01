//
//  TriangleTextureRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 13/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class TriangleTextureRenderer: TriangleRenderer {
    var texture: MyOpenGLTexture?

    override func prepare() {
        let vshSource =
            "#version 330 core" + "\n" +
            "layout (location = 0) in vec3 position;" + "\n" +
            "layout (location = 1) in vec3 color;" + "\n" +
            "layout (location = 2) in vec2 texCoord;" + "\n" +
            "out vec3 ourColor;" + "\n" +
            "out vec2 TexCoord;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "gl_Position = vec4(position.x, position.y, position.z, 1.0);" + "\n" +
            "ourColor = color;" + "\n" +
            "TexCoord = texCoord;" + "\n" +
            "}" + "\n"

        let fshSource =
            "#version 330 core" + "\n" +
            "in vec3 ourColor;" + "\n" +
            "in vec2 TexCoord;" + "\n" +
            "out vec4 color;" + "\n" +
            "uniform sampler2D ourTexture;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "color = texture(ourTexture, TexCoord);" + "\n" +
            "}" + "\n"

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource, fshSource: fshSource)
        self.prepareVertices()
        self.prepareTextures()
    }

    override func render(_ bounds: NSRect) {
        self.shaderProgram?.useProgramWith {
            (program) in
            self.vertexObject?.useVertexObjectWith {
                (vertexObject) in
                self.texture?.useTextureWith {
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }
        }
    }

    override func dispose() {
        super.dispose()
        self.texture = nil
    }

    override func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, +0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
            +0.5, -0.5, +0.0, 0.0, 1.0, 0.0, 1.0, 0.0,
            +0.0, +0.5, +0.0, 0.0, 0.0, 1.0, 0.5, 1.0,
        ]
        self.vertexObject = MyOpenGLVertexObject(vertices: vertices, alignment: [3, 3, 2])
    }

    func prepareTextures() {
        self.texture = MyOpenGLTexture(imageName: "brick_wall")
    }

}
