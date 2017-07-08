//
//  LightingWithMapsRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 29/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class LightingWithMapsRenderer: LightingAndLampRenderer {
    override var renderInterval: Double {
        return 0.0
        // return 1.0 / 60.0
    }
    var rotation: Float = 0.0
    var texture1: MyOpenGLTexture?
    var texture2: MyOpenGLTexture?

    override func prepare() {
        let vshLight = MyOpenGLUtils.loadStringFromResource(name: "LightingWithMaps", type: "vsh")
        let fshLight = MyOpenGLUtils.loadStringFromResource(name: "LightingWithMaps", type: "fsh")
        let vshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "vsh")
        let fshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "fsh")

        self.lightingProgram = MyOpenGLProgram(vshSource: vshLight!, fshSource: fshLight!)
        self.lampProgram = MyOpenGLProgram(vshSource: vshLamp!, fshSource: fshLamp!)
        self.prepareVertices()
        self.prepareTextures()
    }

    override func prepareVertices() {
        let vertices: [GLfloat] = [
            // Positions           // Normals           // Texture Coords
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0,
            0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 0.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0,
            0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0,
            -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 1.0,
            -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0,

            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 0.0,
            0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 0.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 1.0,
            -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 0.0,

            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,
            -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,  1.0, 1.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
            -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
            -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,  0.0, 0.0,
            -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,

            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,
            0.5,  0.5, -0.5,  1.0,  0.0,  0.0,  1.0, 1.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
            0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
            0.5, -0.5,  0.5,  1.0,  0.0,  0.0,  0.0, 0.0,
            0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,

            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,
            0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  1.0, 1.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
            0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
            -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  0.0, 0.0,
            -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,

            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0,
            0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  1.0, 1.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
            0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
            -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  0.0, 0.0,
            -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0
        ]
        self.containerVertex = MyOpenGLVertexObject(vertices: vertices, alignment: [3, 3, 2])
        self.lightVertex = MyOpenGLVertexObject(shared: self.containerVertex!, alignment: [3])
    }

    override func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))

        let radius: GLfloat = 3.0
        let lightX: GLfloat = sinf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightY: GLfloat = 0.0
        let lightZ: GLfloat = cosf(MyOpenGLUtils.DEGREE2RADIAN(self.rotation)) * radius
        let lightPos = GLKVector3Make(lightX, lightY, lightZ)

        let ambientColor = GLKVector3Make(0.2, 0.2, 0.2)
        let diffuseColor = GLKVector3Make(0.5, 0.5, 0.5)
        let lightColor = GLKVector3Make(1.0, 1.0, 1.0)

        self.lightingProgram?.useProgramWith {
            (program) in
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)

            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")
            let lightPosLoc = glGetUniformLocation(program.program, "lightPos")
            let viewPosLoc = glGetUniformLocation(program.program, "viewPos")

            glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z)
            glUniform3f(viewPosLoc, (camera?.position.x)!, (camera?.position.y)!, (camera?.position.z)!)

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            let matDiffuseLoc = glGetUniformLocation(program.program, "material.diffuse")
            let matSpecularLoc = glGetUniformLocation(program.program, "material.specular")
            let matShineLoc = glGetUniformLocation(program.program, "material.shininess")

            glUniform1i(matDiffuseLoc, 0);
            glUniform1i(matSpecularLoc, 1);
            glUniform1f(matShineLoc, 64.0);

            let lightAmbientLoc  = glGetUniformLocation(program.program, "light.ambient");
            let lightDiffuseLoc  = glGetUniformLocation(program.program, "light.diffuse");
            let lightSpecularLoc = glGetUniformLocation(program.program, "light.specular");

            glUniform3f(lightAmbientLoc, ambientColor.x, ambientColor.y, ambientColor.z);
            glUniform3f(lightDiffuseLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z);
            glUniform3f(lightSpecularLoc, lightColor.x, lightColor.y, lightColor.z);

            self.containerVertex?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }

        self.lampProgram?.useProgramWith {
            (program) in
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

            self.lightVertex?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
        }
        glDisable(GLenum(GL_DEPTH_TEST));
        // self.rotation += 1.0
    }

    func prepareTextures() {
        self.texture1 = MyOpenGLTexture(imageName: "container2")
        self.texture2 = MyOpenGLTexture(imageName: "container2_specular")
    }

    override func dispose() {
        super.dispose()
        self.texture1 = nil
        self.texture2 = nil
    }
}
