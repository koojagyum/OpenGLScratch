//
//  MultipleLightsRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 30/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class MultipleLightsRenderer: LightingWithMapsRenderer {
    override var renderInterval: Double {
        return 1.0 / 60.0
    }

    override func prepare() {
        let vshLight = MyOpenGLUtils.loadStringFromResource(name: "LightingWithMaps", type: "vsh")
        let fshLight = MyOpenGLUtils.loadStringFromResource(name: "MultipleLights", type: "fsh")
        self.lightingProgram = MyOpenGLProgram(vshSource: vshLight!, fshSource: fshLight!)

        let vshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "vsh")
        let fshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "fsh")
        self.lampProgram = MyOpenGLProgram(vshSource: vshLamp!, fshSource: fshLamp!)

        self.prepareVertices()
        self.prepareTextures()
    }

    override func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))

        let lightDirection = GLKVector3Make(-0.2, -1.0, -0.3)
        let ambientColor = GLKVector3Make(0.2, 0.2, 0.2)
        let diffuseColor = GLKVector3Make(0.5, 0.5, 0.5)
        let specularColor = GLKVector3Make(1.0, 1.0, 1.0)

        let pointLightPositions = [
            GLKVector3Make( 0.7,  0.2,  2.0),
            GLKVector3Make( 2.3, -3.3, -4.0),
            GLKVector3Make(-4.0,  2.0, -12.0),
            GLKVector3Make( 0.0,  0.0, -3.0)
        ]

        self.lightingProgram?.useProgramWith {
            (program) in
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture1?.textureId)!)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), (self.texture2?.textureId)!)

//            let lightPosLoc = glGetUniformLocation(program.program, "light.position")
//            let lightSpotdirLoc = glGetUniformLocation(program.program, "light.direction")
//            let lightSpotCutOffLoc = glGetUniformLocation(program.program, "light.cutOff")
//            let lightSpotOuterCutOffLoc = glGetUniformLocation(program.program, "light.outerCutOff")

//
//            glUniform3f(lightPosLoc, (camera?.position.x)!, (camera?.position.y)!, (camera?.position.z)!)
//            glUniform3f(lightSpotdirLoc, (camera?.front.x)!, (camera?.front.y)!, (camera?.front.z)!)
//            glUniform1f(lightSpotCutOffLoc, cosf(GLfloat(12.5).radian))
//            glUniform1f(lightSpotOuterCutOffLoc, cosf(GLfloat(17.5).radian))

            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")
            let viewPosLoc = glGetUniformLocation(program.program, "viewPos")

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

            let lightDirLoc = glGetUniformLocation(program.program, "dirLight.direction");
            let lightAmbientLoc  = glGetUniformLocation(program.program, "dirLight.ambient");
            let lightDiffuseLoc  = glGetUniformLocation(program.program, "dirLight.diffuse");
            let lightSpecularLoc = glGetUniformLocation(program.program, "dirLight.specular");

            glUniform3f(lightDirLoc, lightDirection.x, lightDirection.y, lightDirection.z)
            glUniform3f(lightAmbientLoc, ambientColor.x, ambientColor.y, ambientColor.z);
            glUniform3f(lightDiffuseLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z);
            glUniform3f(lightSpecularLoc, specularColor.x, specularColor.y, specularColor.z);

            // Point light 1
            glUniform3f(glGetUniformLocation(program.program, "pointLights[0].position"), pointLightPositions[0].x, pointLightPositions[0].y, pointLightPositions[0].z)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[0].ambient"), 0.05, 0.05, 0.05)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[0].diffuse"), 0.80, 0.80, 0.80)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[0].specular"), 1.00, 1.00, 1.00)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[0].constant"), 1.0)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[0].linear"), 0.09)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[0].quadratic"), 0.032)

            // Point light 2
            glUniform3f(glGetUniformLocation(program.program, "pointLights[1].position"), pointLightPositions[1].x, pointLightPositions[1].y, pointLightPositions[1].z)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[1].ambient"), 0.05, 0.05, 0.05)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[1].diffuse"), 0.80, 0.80, 0.80)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[1].specular"), 1.00, 1.00, 1.00)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[1].constant"), 1.0)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[1].linear"), 0.09)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[1].quadratic"), 0.032)

            // Point light 3
            glUniform3f(glGetUniformLocation(program.program, "pointLights[2].position"), pointLightPositions[2].x, pointLightPositions[2].y, pointLightPositions[2].z)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[2].ambient"), 0.05, 0.05, 0.05)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[2].diffuse"), 0.80, 0.80, 0.80)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[2].specular"), 1.00, 1.00, 1.00)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[2].constant"), 1.0)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[2].linear"), 0.09)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[2].quadratic"), 0.032)

            // Point light 4
            glUniform3f(glGetUniformLocation(program.program, "pointLights[3].position"), pointLightPositions[3].x, pointLightPositions[3].y, pointLightPositions[3].z)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[3].ambient"), 0.05, 0.05, 0.05)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[3].diffuse"), 0.80, 0.80, 0.80)
            glUniform3f(glGetUniformLocation(program.program, "pointLights[3].specular"), 1.00, 1.00, 1.00)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[3].constant"), 1.0)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[3].linear"), 0.09)
            glUniform1f(glGetUniformLocation(program.program, "pointLights[3].quadratic"), 0.032)

            self.containerVertex?.useVertexObjectWith {
                (vertexObject) in
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
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
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

            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            self.lightVertex?.useVertexObjectWith {
                (vertexObject) in
                for i in 0...3 {
                    var model = GLKMatrix4Identity
                    model = GLKMatrix4TranslateWithVector3(model, pointLightPositions[i])
                    model = GLKMatrix4Scale(model, 0.2, 0.2, 0.2) // Make it smaller cube
                    MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST));
        self.rotation += 1.0
    }
}
