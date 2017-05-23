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
    var modelLoc: GLint = 0
    var viewLoc: GLint = 0
    var projLoc: GLint = 0

    override func prepare() {
        let vshSource =
            "#version 330 core" + "\n" +
            "layout (location = 0) in vec3 position;" + "\n" +
            "layout (location = 2) in vec2 texCoord;" + "\n" +
            "out vec2 TexCoord;" + "\n" +
            "uniform mat4 model;" + "\n" +
            "uniform mat4 view;" + "\n" +
            "uniform mat4 projection;" + "\n" +
            "void main()" + "\n" +
            "{" + "\n" +
            "gl_Position = projection * view * model * vec4(position, 1.0);" + "\n" +
            "TexCoord = texCoord;" + "\n" +
            "}" + "\n"

        let fshSource =
            "#version 330 core" + "\n" +
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
        self.modelLoc = glGetUniformLocation((self.shaderProgram?.program)!, "model")
        self.viewLoc = glGetUniformLocation((self.shaderProgram?.program)!, "view")
        self.projLoc = glGetUniformLocation((self.shaderProgram?.program)!, "projection")
    }
    
    override func render(_ bounds: NSRect) {
        if let program = self.shaderProgram, program.useProgram() {
            var model = GLKMatrix4MakeXRotation(MyOpenGLUtils.DEGREE2RADIAN(-55.0))
            var view = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0)
            var projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)

            self.uniformMatrix4fv(self.modelLoc, 1, GLboolean(GL_FALSE), &model)
            self.uniformMatrix4fv(self.viewLoc, 1, GLboolean(GL_FALSE), &view)
            self.uniformMatrix4fv(self.projLoc, 1, GLboolean(GL_FALSE), &projection)

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

    func uniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: inout GLKMatrix4) {
        withUnsafePointer(to: &value.m) {
            $0.withMemoryRebound(to: Float.self, capacity: 16) {
                glUniformMatrix4fv(location, count, transpose, $0)
            }
        }
    }
}
