//
//  LightingWithMaterialRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 29/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class LightingWithMaterialRenderer: LightingAndLampRenderer {
    override var renderInterval: Double {
        return 1.0 / 60.0
    }
    var rotation: Float = 0.0

    override func prepare() {
        let vshLight = MyOpenGLUtils.loadStringFromResource(name: "Lighting", type: "vsh")
        let fshLight = MyOpenGLUtils.loadStringFromResource(name: "LightingWithMaterial", type: "fsh")
        let vshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "vsh")
        let fshLamp = MyOpenGLUtils.loadStringFromResource(name: "Lamp", type: "fsh")

        self.lightingProgram = MyOpenGLProgram(vshSource: vshLight!, fshSource: fshLight!)
        self.lampProgram = MyOpenGLProgram(vshSource: vshLamp!, fshSource: fshLamp!)
        self.prepareVertices()
    }

    override func render(_ bounds: NSRect) {
        glEnable(GLenum(GL_DEPTH_TEST))

        let lightPos = GLKVector3Make(0.2, 0.0, 1.0)
        let lightColor = GLKVector3Make(sinf(self.rotation.radian * 2.0), sinf(self.rotation.radian * 0.7), sinf(self.rotation.radian * 1.3))
        let diffuseColor = lightColor * 0.5 // Decrease the influence
        let ambientColor = diffuseColor * 0.2 // Low influence

        self.lightingProgram?.useProgramWith {
            (program) in
            let modelLoc = glGetUniformLocation(program.program, "model")
            let viewLoc = glGetUniformLocation(program.program, "view")
            let projLoc = glGetUniformLocation(program.program, "projection")
            let lightPosLoc = glGetUniformLocation(program.program, "lightPos")
            let objectColorLoc = glGetUniformLocation(program.program, "objectColor")
            let viewPosLoc = glGetUniformLocation(program.program, "viewPos")

            glUniform3f(objectColorLoc, 1.0, 0.5, 0.31)
            glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z)
            glUniform3f(viewPosLoc, (camera?.position.x)!, (camera?.position.y)!, (camera?.position.z)!)

            var model = GLKMatrix4Identity
            var projection = GLKMatrix4MakePerspective((camera?.zoom.radian)!, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

            MyOpenGLUtils.uniformMatrix4fv(modelLoc, 1, GLboolean(GL_FALSE), &model)
            MyOpenGLUtils.uniformMatrix4fv(projLoc, 1, GLboolean(GL_FALSE), &projection)
            if var view = self.camera?.viewMatrix {
                MyOpenGLUtils.uniformMatrix4fv(viewLoc, 1, GLboolean(GL_FALSE), &view)
            }

            let matAmbientLoc = glGetUniformLocation(program.program, "material.ambient")
            let matDiffuseLoc = glGetUniformLocation(program.program, "material.diffuse")
            let matSpecularLoc = glGetUniformLocation(program.program, "material.specular")
            let matShineLoc = glGetUniformLocation(program.program, "material.shininess")

            glUniform3f(matAmbientLoc,  1.0, 0.5, 0.31);
            glUniform3f(matDiffuseLoc,  1.0, 0.5, 0.31);
            glUniform3f(matSpecularLoc, 0.5, 0.5, 0.5);
            glUniform1f(matShineLoc,    32.0);

            let lightAmbientLoc  = glGetUniformLocation(program.program, "light.ambient");
            let lightDiffuseLoc  = glGetUniformLocation(program.program, "light.diffuse");
            let lightSpecularLoc = glGetUniformLocation(program.program, "light.specular");

            glUniform3f(lightAmbientLoc, ambientColor.x, ambientColor.y, ambientColor.z);
            glUniform3f(lightDiffuseLoc, diffuseColor.x, diffuseColor.y, diffuseColor.z);
            glUniform3f(lightSpecularLoc, 1.0, 1.0, 1.0);

            self.containerVertex?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
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
        self.rotation += 1.0
    }
}
