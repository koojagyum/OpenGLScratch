//
//  SkyboxReflectRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 25/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class SkyboxReflectRenderer: SkyboxRenderer {
    override func prepareProgram() {
        super.prepareProgram()
        let cubeVshSource = MyOpenGLUtils.loadStringFromResource(name: "SkyboxReflectCube", type: "vsh")
        let cubeFshSource = MyOpenGLUtils.loadStringFromResource(name: "SkyboxReflectCube", type: "fsh")
        self.cubeProgram = MyOpenGLProgram(vshSource: cubeVshSource!, fshSource: cubeFshSource!)
    }

    override func prepareVertices() {
        super.prepareVertices()
        let cubeVertices: [GLfloat] = [
            0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
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
        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3, 3])
    }

    override func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let view = self.camera?.viewMatrix
        let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)

        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LESS))
        self.cubeProgram?.useProgramWith {
            (program) in
            program.setMat4(name: "model", value: GLKMatrix4Identity)
            program.setMat4(name: "view", value: view!)
            program.setMat4(name: "projection", value: projection)
            program.setVec3(name: "cameraPos", value: (camera?.position)!)

            self.cubeVertexObject?.useVertexObjectWith {
                self.skyboxTexture?.useTextureWith {
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.cubeVertexObject!.count))
                }
            }
        }

        glDepthFunc(GLenum(GL_LEQUAL))
        self.skyboxProgram?.useProgramWith {
            (program) in
            let viewWithoutTrans =
                GLKMatrix4Make(view!.m00, view!.m01, view!.m02, 0.0,
                               view!.m10, view!.m11, view!.m12, 0.0,
                               view!.m20, view!.m21, view!.m22, 0.0,
                               0.0, 0.0, 0.0, 1.0)
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: viewWithoutTrans)
            
            self.skyboxVertexObject?.useVertexObjectWith {
                self.skyboxTexture?.useTextureWith {
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.skyboxVertexObject!.count))
                }
            }
        }
        glDisable(GLenum(GL_DEPTH_TEST))
    }
}
