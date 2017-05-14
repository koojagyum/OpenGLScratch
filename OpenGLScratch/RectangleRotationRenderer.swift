//
//  RectangleRotationRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 14/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3
import GLKit

class RectangleRotationRenderer: RectangleTextureRenderer {
    override var renderInterval: Double {
        return 1.0 / 60.0
    }
    var transformLoc: GLint = 0
    var rotation: Float = 0.0

    override func prepare() {
        let vshSource =
            "#version 330 core" + "\n" +
            "layout (location = 0) in vec3 position;" + "\n" +
            "layout (location = 1) in vec3 color;" + "\n" +
            "layout (location = 2) in vec2 texCoord;" + "\n" +
            "out vec3 ourColor;" + "\n" +
            "out vec2 TexCoord;" + "\n" +
            "uniform mat4 transform;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "gl_Position = transform * vec4(position, 1.0);" + "\n" +
            "ourColor = color;" + "\n" +
            "TexCoord = texCoord;" + "\n" +
            "}" + "\n"

        let fshSource =
            "#version 330 core" + "\n" +
            "in vec3 ourColor;" + "\n" +
            "in vec2 TexCoord;" + "\n" +
            "out vec4 color;" + "\n" +
            "uniform sampler2D ourTexture1;" + "\n" +
            "uniform sampler2D ourTexture2;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "color = mix(texture(ourTexture1, TexCoord), texture(ourTexture2, TexCoord), 0.2);" + "\n" +
            "}" + "\n"

        self.shaderProgram = MyOpenGLProgram(vshSource: vshSource, fshSource: fshSource)
        self.prepareVertices()
        self.prepareTextures()
        self.transformLoc = glGetUniformLocation((self.shaderProgram?.program)!, "transform")
    }

    override func render() {
        if let program = self.shaderProgram, program.useProgram() {
            var trans: GLKMatrix4 = GLKMatrix4Identity

            self.rotation += 1.0
            trans = GLKMatrix4RotateWithVector3(trans, DEGREE2RADIAN(self.rotation), GLKVector3Make(0.0, 0.0, 1.0))

            // let m = UnsafeMutablePointer(&trans.m)
            // let p = UnsafeRawPointer(m).bindMemory(to: Float.self, capacity: 16)
            // glUniformMatrix4fv(self.transformLoc, 1, GLboolean(GL_FALSE), p)

            withUnsafePointer(to: &trans.m) {
                $0.withMemoryRebound(to: Float.self, capacity: 16) {
                    glUniformMatrix4fv(self.transformLoc, 1, GLboolean(GL_FALSE), $0)
                }
            }

            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture1"), 0)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)
            glUniform1i(glGetUniformLocation(program.program, "ourTexture2"), 1)

            glBindVertexArray(self.vao)
            glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)
            glBindVertexArray(0)

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }
    }

    func DEGREE2RADIAN(_ degree: Float) -> Float {
        return degree * Float.pi / 180.0
    }
}
