//
//  SpotLightRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 29/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class SpotLightRenderer: LightingWithMapsRenderer {
    override func prepare() {
        let vshLight = MyOpenGLUtils.loadStringFromResource(name: "LightingWithMaps", type: "vsh")
        let fshLight = MyOpenGLUtils.loadStringFromResource(name: "SpotLight", type: "fsh")

        self.lightingProgram = MyOpenGLProgram(vshSource: vshLight!, fshSource: fshLight!)

        self.prepareVertices()
        self.prepareTextures()
    }

    override func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))

        let ambientColor = GLKVector3Make(0.2, 0.2, 0.2)
        let diffuseColor = GLKVector3Make(0.5, 0.5, 0.5)
        let lightColor = GLKVector3Make(1.0, 1.0, 1.0)

        if let program = self.lightingProgram, program.useProgram() {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)

            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")
            let lightPosLoc = glGetUniformLocation(program.program, "light.position")
            let lightSpotdirLoc = glGetUniformLocation(program.program, "light.direction")
            let lightSpotCutOffLoc = glGetUniformLocation(program.program, "light.cutOff")
            let lightSpotOuterCutOffLoc = glGetUniformLocation(program.program, "light.outerCutOff")
            let viewPosLoc = glGetUniformLocation(program.program, "viewPos")

            glUniform3f(lightPosLoc, (camera?.position.x)!, (camera?.position.y)!, (camera?.position.z)!)
            glUniform3f(lightSpotdirLoc, (camera?.front.x)!, (camera?.front.y)!, (camera?.front.z)!)
            glUniform1f(lightSpotCutOffLoc, cosf(GLfloat(12.5).radian))
            glUniform1f(lightSpotOuterCutOffLoc, cosf(GLfloat(17.5).radian))

            glUniform3f(viewPosLoc, (camera?.position.x)!, (camera?.position.y)!, (camera?.position.z)!)

            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

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

            let constantPos = glGetUniformLocation(program.program, "light.constant")
            let linearPos = glGetUniformLocation(program.program, "light.linear")
            let quadraticPos = glGetUniformLocation(program.program, "light.quadratic")

            glUniform1f(constantPos, 1.0)
            glUniform1f(linearPos, 0.09)
            glUniform1f(quadraticPos, 0.032)

            glBindVertexArray(self.containerVao)

            let cubePositions: [GLKVector3] = [
                GLKVector3Make(+0.0, +0.0, +0.0),
                GLKVector3Make(+2.0, +5.0, -15.0),
                GLKVector3Make(-1.5, -2.2, -2.5),
                GLKVector3Make(-3.8, -2.0, -12.3),
                GLKVector3Make(+2.4, -0.4, -3.5),
                GLKVector3Make(-1.7, +3.0, -7.5),
                GLKVector3Make(+1.3, -2.0, -2.5),
                GLKVector3Make(+1.5, +2.0, -2.5),
                GLKVector3Make(+1.5, +0.2, -1.5),
                GLKVector3Make(-1.3, +1.0, -1.5),
                ]
            for i in 0...9 {
                let angle: GLfloat = 20.0 * Float(i)
                var model = GLKMatrix4Identity
                model = GLKMatrix4TranslateWithVector3(model, cubePositions[i])
                model = GLKMatrix4RotateWithVector3(model, MyOpenGLUtils.DEGREE2RADIAN(angle), GLKVector3Make(1.0, 0.3, 0.5))
                model = GLKMatrix4RotateWithVector3(model, MyOpenGLUtils.DEGREE2RADIAN(self.rotation), GLKVector3Make(0.5, 1.0, 0.0))
                MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            }

            glBindVertexArray(0)

            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        }
        glDisable(GLenum(GL_DEPTH_TEST));
    }
}
