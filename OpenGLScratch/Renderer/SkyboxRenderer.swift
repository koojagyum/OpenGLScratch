//
//  SkyboxRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 23/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class SkyboxRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }
    var rotation: Float = 0.0

    var cubeProgram: MyOpenGLProgram?
    var skyboxProgram: MyOpenGLProgram?

    var cubeVertexObject: MyOpenGLVertexObject?
    var skyboxVertexObject: MyOpenGLVertexObject?

    var cubeTexture: MyOpenGLTexture?
    var skyboxTexture: MyOpenGLTexture?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTextures()
    }

    func prepareProgram() {
        let cubeVshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "vsh")
        let cubeFshSource = MyOpenGLUtils.loadStringFromResource(name: "DepthTest", type: "fsh")
        self.cubeProgram = MyOpenGLProgram(vshSource: cubeVshSource!, fshSource: cubeFshSource!)

        let skyboxVshSource = MyOpenGLUtils.loadStringFromResource(name: "Skybox", type: "vsh")
        let skyboxFshSource = MyOpenGLUtils.loadStringFromResource(name: "Skybox", type: "fsh")
        self.skyboxProgram = MyOpenGLProgram(vshSource: skyboxVshSource!, fshSource: skyboxFshSource!)
    }

    func prepareVertices() {
        let cubeVertices: [GLfloat] = [
            // positions      // texture Coords
            -0.5, -0.5, -0.5,  0.0, 0.0,
            0.5, -0.5, -0.5,  1.0, 0.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            -0.5,  0.5, -0.5,  0.0, 1.0,
            -0.5, -0.5, -0.5,  0.0, 0.0,

            -0.5, -0.5,  0.5,  0.0, 0.0,
            0.5, -0.5,  0.5,  1.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            -0.5,  0.5,  0.5,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0, 0.0,

            -0.5,  0.5,  0.5,  1.0, 0.0,
            -0.5,  0.5, -0.5,  1.0, 1.0,
            -0.5, -0.5, -0.5,  0.0, 1.0,
            -0.5, -0.5, -0.5,  0.0, 1.0,
            -0.5, -0.5,  0.5,  0.0, 0.0,
            -0.5,  0.5,  0.5,  1.0, 0.0,

            0.5,  0.5,  0.5,  1.0, 0.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            0.5, -0.5, -0.5,  0.0, 1.0,
            0.5, -0.5, -0.5,  0.0, 1.0,
            0.5, -0.5,  0.5,  0.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 0.0,

            -0.5, -0.5, -0.5,  0.0, 1.0,
            0.5, -0.5, -0.5,  1.0, 1.0,
            0.5, -0.5,  0.5,  1.0, 0.0,
            0.5, -0.5,  0.5,  1.0, 0.0,
            -0.5, -0.5,  0.5,  0.0, 0.0,
            -0.5, -0.5, -0.5,  0.0, 1.0,

            -0.5,  0.5, -0.5,  0.0, 1.0,
            0.5,  0.5, -0.5,  1.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 0.0,
            -0.5,  0.5,  0.5,  0.0, 0.0,
            -0.5,  0.5, -0.5,  0.0, 1.0
        ]
        let skyboxVertices: [GLfloat] = [
            // positions
            -1.0,  1.0, -1.0,
            -1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            1.0,  1.0, -1.0,
            -1.0,  1.0, -1.0,
            
            -1.0, -1.0,  1.0,
            -1.0, -1.0, -1.0,
            -1.0,  1.0, -1.0,
            -1.0,  1.0, -1.0,
            -1.0,  1.0,  1.0,
            -1.0, -1.0,  1.0,
            
            1.0, -1.0, -1.0,
            1.0, -1.0,  1.0,
            1.0,  1.0,  1.0,
            1.0,  1.0,  1.0,
            1.0,  1.0, -1.0,
            1.0, -1.0, -1.0,
            
            -1.0, -1.0,  1.0,
            -1.0,  1.0,  1.0,
            1.0,  1.0,  1.0,
            1.0,  1.0,  1.0,
            1.0, -1.0,  1.0,
            -1.0, -1.0,  1.0,
            
            -1.0,  1.0, -1.0,
            1.0,  1.0, -1.0,
            1.0,  1.0,  1.0,
            1.0,  1.0,  1.0,
            -1.0,  1.0,  1.0,
            -1.0,  1.0, -1.0,
            
            -1.0, -1.0, -1.0,
            -1.0, -1.0,  1.0,
            1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            -1.0, -1.0,  1.0,
            1.0, -1.0,  1.0
        ]

        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3, 2])
        self.skyboxVertexObject = MyOpenGLVertexObject(vertices: skyboxVertices, alignment: [3])
    }

    func prepareTextures() {
        self.cubeTexture = MyOpenGLTexture(imageName: "container")
        let cubemapPaths: [String] = [
            "/Users/koodev/Workspace/Resource/Cubemap/skybox/right.jpg",
            "/Users/koodev/Workspace/Resource/Cubemap/skybox/left.jpg",
            "/Users/koodev/Workspace/Resource/Cubemap/skybox/top.jpg",
            "/Users/koodev/Workspace/Resource/Cubemap/skybox/bottom.jpg",
            "/Users/koodev/Workspace/Resource/Cubemap/skybox/back.jpg",
            "/Users/koodev/Workspace/Resource/Cubemap/skybox/front.jpg",
        ]
        self.skyboxTexture = MyOpenGLCubemapTexture(facePaths: cubemapPaths)
    }

    func render(_ bounds: NSRect) {
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

            self.cubeVertexObject?.useVertexObjectWith {
                (vertexObject) in
                self.cubeTexture?.useTextureWith {
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
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
                (vertexObject) in
                self.skyboxTexture?.useTextureWith {
                    glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
                }
            }
        }
        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.cubeProgram = nil
        self.skyboxProgram = nil
        self.cubeVertexObject = nil
        self.skyboxVertexObject = nil
        self.cubeTexture = nil
        self.skyboxTexture = nil
    }
}
