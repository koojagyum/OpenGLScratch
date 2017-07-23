//
//  PointShadowRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 19/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class PointShadowRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 1.0/60.0
    }
    var tick: Float = 0.0

    var pointShadowProgram: MyOpenGLProgram?
    var pointShadowDepthProgram: MyOpenGLProgram?
    var lampProgram: MyOpenGLProgram?
    var woodTexture: MyOpenGLTexture?
    var cubeVertexObject: MyOpenGLVertexObject?
    var lampVertexObject: MyOpenGLVertexObject?
    var depthCubeFramebuffer: MyOpenGLFramebufferForDepthCubemap?

    let SHADOW_WIDTH = 1024
    let SHADOW_HEIGHT = 1024

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTexture()
        self.prepareFramebuffer()
    }

    func prepareProgram() {
        self.pointShadowProgram = MyOpenGLUtils.createProgramWithName(name: "PointShadow")
        self.pointShadowDepthProgram = MyOpenGLUtils.createProgramWithNames(vshName: "PointShadowDepth", fshName: "PointShadowDepth", gshName: "PointShadowDepth")
        self.lampProgram = MyOpenGLUtils.createProgramWithName(name: "Lamp")
    }

    func prepareVertices() {
        let cubeVertices: [GLfloat] = [
            // back face
            -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 0.0, // bottom-left
            1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 1.0, // top-right
            1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 0.0, // bottom-right
            1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 1.0, 1.0, // top-right
            -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 0.0, // bottom-left
            -1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 0.0, 1.0, // top-left
            // front face
            -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 0.0, // bottom-left
            1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 0.0, // bottom-right
            1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 1.0, // top-right
            1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 1.0, 1.0, // top-right
            -1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 1.0, // top-left
            -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0.0, 0.0, // bottom-left
            // left face
            -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 1.0, 0.0, // top-right
            -1.0,  1.0, -1.0, -1.0,  0.0,  0.0, 1.0, 1.0, // top-left
            -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0.0, 1.0, // bottom-left
            -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0.0, 1.0, // bottom-left
            -1.0, -1.0,  1.0, -1.0,  0.0,  0.0, 0.0, 0.0, // bottom-right
            -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 1.0, 0.0, // top-right
            // right face
            1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 1.0, 0.0, // top-left
            1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0.0, 1.0, // bottom-right
            1.0,  1.0, -1.0,  1.0,  0.0,  0.0, 1.0, 1.0, // top-right
            1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0.0, 1.0, // bottom-right
            1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 1.0, 0.0, // top-left
            1.0, -1.0,  1.0,  1.0,  0.0,  0.0, 0.0, 0.0, // bottom-left
            // bottom face
            -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0.0, 1.0, // top-right
            1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 1.0, 1.0, // top-left
            1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 1.0, 0.0, // bottom-left
            1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 1.0, 0.0, // bottom-left
            -1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 0.0, 0.0, // bottom-right
            -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0.0, 1.0, // top-right
            // top face
            -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0.0, 1.0, // top-left
            1.0,  1.0 , 1.0,  0.0,  1.0,  0.0, 1.0, 0.0, // bottom-right
            1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 1.0, 1.0, // top-right
            1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 1.0, 0.0, // bottom-right
            -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0.0, 1.0, // top-left
            -1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 0.0, 0.0  // bottom-left
        ]
        self.cubeVertexObject = MyOpenGLVertexObject(vertices: cubeVertices, alignment: [3,3,2])

        let lampVertices: [GLfloat] = [
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
        self.lampVertexObject = MyOpenGLVertexObject(vertices: lampVertices, alignment: [3,3])
    }

    func prepareTexture() {
        self.woodTexture = MyOpenGLTexture(imageName: "wood")
    }

    func prepareFramebuffer() {
        self.depthCubeFramebuffer = MyOpenGLFramebufferForDepthCubemap(width: self.SHADOW_WIDTH, height: self.SHADOW_HEIGHT)
    }

    func render(_ bounds: NSRect) {
        let lightPosZ = sinf(self.tick.radian * 0.5) * 3.0
        let lightPos = GLKVector3Make(0.0, 0.0, lightPosZ)

        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_CULL_FACE))
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let near_plane: GLfloat = 1.0
        let far_plane: GLfloat = 25.0
        let shadowProjection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(90.0), (Float(self.SHADOW_WIDTH) / Float(self.SHADOW_WIDTH)), near_plane, far_plane)
        let shadowTransforms: [GLKMatrix4] = [
            shadowProjection * GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, lightPos.x + 1.0, lightPos.y + 0.0, lightPos.z + 0.0, +0.0, -1.0, +0.0),
            shadowProjection * GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, lightPos.x - 1.0, lightPos.y + 0.0, lightPos.z + 0.0, +0.0, -1.0, +0.0),
            shadowProjection * GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, lightPos.x + 0.0, lightPos.y + 1.0, lightPos.z + 0.0, +0.0, +0.0, +1.0),
            shadowProjection * GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, lightPos.x + 0.0, lightPos.y - 1.0, lightPos.z + 0.0, +0.0, +0.0, -1.0),
            shadowProjection * GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, lightPos.x + 0.0, lightPos.y + 0.0, lightPos.z + 1.0, +0.0, -1.0, +0.0),
            shadowProjection * GLKMatrix4MakeLookAt(lightPos.x, lightPos.y, lightPos.z, lightPos.x + 0.0, lightPos.y + 0.0, lightPos.z - 1.0, +0.0, -1.0, +0.0),
        ]

        let depthCubemapTexture = self.depthCubeFramebuffer?.draw {
            glClear(GLbitfield(GL_DEPTH_BUFFER_BIT));
            self.pointShadowDepthProgram?.useProgramWith {
                (program) in
                _ = shadowTransforms.enumerated().map {
                    program.setMat4(name: "shadowMatrices[\($0)]", value: $1)
                }

                program.setFloat(name: "far_plane", value: far_plane)
                program.setVec3(name: "lightPos", value: lightPos)
                self.renderScene(program: program)
            }
        }

        self.pointShadowProgram?.useProgramWith {
            (program) in
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
            program.setInt(name: "diffuseTexture", value: 0)
            program.setInt(name: "depthMap", value: 1)

            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = camera!.viewMatrix
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)

            // set lighting uniforms
            program.setVec3(name: "lightPos", value: lightPos)
            program.setVec3(name: "viewPos", value: camera!.position)
            program.setInt(name: "shadows", value: 1) // enable/disable?
            program.setFloat(name: "far_plane", value: far_plane)

            glActiveTexture(GLenum(GL_TEXTURE0))
            self.woodTexture?.useTextureWith {
                glActiveTexture(GLenum(GL_TEXTURE1))
                glBindTexture(GLenum(GL_TEXTURE_CUBE_MAP), depthCubemapTexture!)
                self.renderScene(program: program)
                glBindTexture(GLenum(GL_TEXTURE_CUBE_MAP), 0)
            }
        }

        self.lampProgram?.useProgramWith {
            (program) in
            glClear(GLbitfield(GL_DEPTH_BUFFER_BIT));
            glDisable(GLenum(GL_CULL_FACE))
            let model = GLKMatrix4Scale(GLKMatrix4MakeTranslation(lightPos.x, lightPos.y, lightPos.z), 0.2, 0.2, 0.2)
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = self.camera!.viewMatrix

            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)
            program.setMat4(name: "model", value: model)

            self.lampVertexObject?.useVertexObjectWith {
                (vertexObject) in
                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
            }
            glEnable(GLenum(GL_CULL_FACE))
        }

        glDisable(GLenum(GL_CULL_FACE))
        glDisable(GLenum(GL_DEPTH_TEST))
        self.tick += 1.0
    }

    func renderScene(program: MyOpenGLProgram) {
        // room normal
        glDisable(GLenum(GL_CULL_FACE)) // note that we disable culling here since we render 'inside' the cube instead of the usual 'outside' which throws off the normal culling methods
        program.setInt(name: "reverse_normals", value: 1) // A small little hack to invert normals when drawing cube from the inside so lighting still works
        self.renderCube(program: program, model: GLKMatrix4MakeScale(5.0, 5.0, 5.0))
        program.setInt(name: "reverse_normals", value: 0) // and of course disable it
        glEnable(GLenum(GL_CULL_FACE))

        // cubes
        self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(4.0, -3.5, 0.0), 0.5, 0.5, 0.5))
        self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(2.0, 3.0, 1.0), 0.75, 0.75, 0.75))
        self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(-3.0, -1.0, 0.0), 0.5, 0.5, 0.5))
        self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4MakeTranslation(-1.5, 1.0, 1.5), 0.5, 0.5, 0.5))
        self.renderCube(program: program, model: GLKMatrix4Scale(GLKMatrix4Rotate(GLKMatrix4MakeTranslation(-1.5, 2.0, -3.0), Float(60.0).radian, 1.0, 0.0, 1.0), 0.75, 0.75, 0.75))
    }

    func renderCube(program: MyOpenGLProgram, model: GLKMatrix4) {
        program.setMat4(name: "model", value: model)
        self.cubeVertexObject?.useVertexObjectWith {
            (vertexObject) in
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexObject.count))
        }
    }

    func dispose() {
        self.pointShadowProgram = nil
        self.pointShadowDepthProgram = nil
        self.woodTexture = nil
        self.cubeVertexObject = nil
        self.depthCubeFramebuffer = nil
        self.lampProgram = nil
        self.lampVertexObject = nil
    }
}
