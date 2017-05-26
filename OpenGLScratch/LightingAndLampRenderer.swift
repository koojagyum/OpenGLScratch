//
//  LightingAndLampRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 23/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class LightingAndLampRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var lightingProgram: MyOpenGLProgram?
    var lampProgram: MyOpenGLProgram?

    var containerVao: GLuint = 0
    var lightVao: GLuint = 0
    var vbo: GLuint = 0

    func prepare() {
        let NL = "\n"
        let vshLight =
        "#version 330 core" + NL +
        "layout (location = 0) in vec3 position;" + NL +
        "layout (location = 1) in vec3 normal;" + NL +
        "out vec3 FragPos;" + NL +
        "out vec3 Normal;" + NL +
        "uniform mat4 model;" + NL +
        "uniform mat4 view;" + NL +
        "uniform mat4 projection;" + NL +
        "void main()" + NL +
        "{" + NL +
        "   gl_Position = projection * view * model * vec4(position, 1.0f);" + NL +
        "   FragPos = vec3(model * vec4(position, 1.0f));" + NL +
        // "   Normal = normal;" + NL +
        "   Normal = mat3(transpose(inverse(model))) * normal;" + NL +
        "}"
        let fshLight =
        "#version 330 core" + NL +
        "in vec3 FragPos;" + NL +
        "in vec3 Normal;" + NL +
        "out vec4 color;" + NL +
        "uniform vec3 objectColor;" + NL +
        "uniform vec3 lightColor;" + NL +
        "uniform vec3 lightPos;" + NL +
        "void main()" + NL +
        "{" + NL +
        "   vec3 norm = normalize(Normal);" + NL +
        "   vec3 lightDir = normalize(lightPos - FragPos);" + NL +
        "   float diff = max(dot(norm, lightDir), 0.0);" + NL +
        "   vec3 diffuse = diff * lightColor;" + NL +
        "   float ambientStrength = 0.1f;" + NL +
        "   vec3 ambient = ambientStrength * lightColor;" + NL +
        "   vec3 result = (ambient + diffuse) * objectColor;" + NL +
        "   color = vec4(result, 1.0f);" + NL +
        "}"
        let vshLamp = vshLight
        let fshLamp =
        "#version 330 core" + NL +
        "out vec4 color;" + NL +
        "void main()" + NL +
        "{" + NL +
        "   color = vec4(1.0f);" + NL + // Set alle 4 vector values to 1.0f
        "}"

        self.lightingProgram = MyOpenGLProgram(vshSource: vshLight, fshSource: fshLight)
        self.lampProgram = MyOpenGLProgram(vshSource: vshLamp, fshSource: fshLamp)
        self.prepareVertices()
    }

    func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))
        let lightPos = GLKVector3Make(1.2, 1.0, 2.0)
        if let program = self.lightingProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")
            let lightPosLoc = glGetUniformLocation(program.program, "lightPos")
            let objectColorLoc = glGetUniformLocation(program.program, "objectColor")
            let lightColorLoc = glGetUniformLocation(program.program, "lightColor")

            glUniform3f(objectColorLoc, 1.0, 0.5, 0.31)
            glUniform3f(lightColorLoc, 1.0, 0.5, 1.0)
            glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z)

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            glBindVertexArray(self.containerVao)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            glBindVertexArray(0)
        }

        if let program = self.lampProgram, program.useProgram() {
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

            model = GLKMatrix4TranslateWithVector3(model, lightPos)
            model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2) // Make it smaller cube

            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            glBindVertexArray(self.lightVao)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            glBindVertexArray(0)
        }
        glDisable(GLenum(GL_DEPTH_TEST));
    }

    func dispose() {
        glDeleteVertexArrays(1, &self.containerVao)
        glDeleteVertexArrays(1, &self.lightVao)
        glDeleteBuffers(1, &self.vbo)
        self.lightingProgram = nil
        self.lampProgram = nil
    }

    func prepareVertices() {
        let vertices: [GLfloat] = [
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
            0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,

            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
            0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,

            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
            -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
            -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
            0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
            0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
            0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
            0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
        ]

        glGenVertexArrays(1, &self.containerVao)
        glGenVertexArrays(1, &self.lightVao)

        glGenBuffers(1, &self.vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        glBindVertexArray(self.containerVao)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), nil)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLfloat>.stride * 3))
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glBindVertexArray(0)

        glBindVertexArray(self.lightVao)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(6 * MemoryLayout<GLfloat>.stride), nil)
        glEnableVertexAttribArray(0)
        glBindVertexArray(0)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
}
