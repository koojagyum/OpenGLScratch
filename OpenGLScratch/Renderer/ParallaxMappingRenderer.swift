//
//  ParallaxMappingRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 04/08/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class ParallaxMappingRenderer: MyOpenGLRendererDelegate, MyOpenGLKeyConsumable {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0 // 1.0/60.0
    }
    var tick: Float = 0.0
    var heightScale: Float = 0.1

    var parallaxMappingProgram: MyOpenGLProgram?
    var diffuseMap: MyOpenGLTexture?
    var normalMap: MyOpenGLTexture?
    var heightMap: MyOpenGLTexture?
    var quadVertexObject: MyOpenGLVertexObject?

    func prepare() {
        self.prepareProgram()
        self.prepareVertices()
        self.prepareTexture()
    }

    func prepareProgram() {
        self.parallaxMappingProgram = MyOpenGLUtils.createProgramWithName(name: "ParallaxMapping")
    }

    func prepareVertices() {
        // positions
        let pos1 = GLKVector3Make(-1.0, +1.0, 0.0)
        let pos2 = GLKVector3Make(-1.0, -1.0, 0.0)
        let pos3 = GLKVector3Make(+1.0, -1.0, 0.0)
        let pos4 = GLKVector3Make(+1.0, +1.0, 0.0)
        // texture coordinates
        let uv1 = GLKVector2Make(0.0, 1.0)
        let uv2 = GLKVector2Make(0.0, 0.0)
        let uv3 = GLKVector2Make(1.0, 0.0)
        let uv4 = GLKVector2Make(1.0, 1.0)
        // normal vector
        let nm = GLKVector3Make(0.0, 0.0, 1.0)

        // calculate tangent/bitangent vectors of both triangles
        // triangle 1
        // ----------
        let tangent1 = self.calculateTangentVector(edge1: pos2 - pos1, edge2: pos3 - pos1, deltaUV1: uv2 - uv1, deltaUV2: uv3 - uv1)
        let bitangent1 = self.calculateBiTangentVector(edge1: pos2 - pos1, edge2: pos3 - pos1, deltaUV1: uv2 - uv1, deltaUV2: uv3 - uv1)

        // triangle 2
        // ----------
        let tangent2 = self.calculateTangentVector(edge1: pos3 - pos1, edge2: pos4 - pos1, deltaUV1: uv3 - uv1, deltaUV2: uv4 - uv1)
        let bitangent2 = self.calculateBiTangentVector(edge1: pos3 - pos1, edge2: pos4 - pos1, deltaUV1: uv3 - uv1, deltaUV2: uv4 - uv1)

        let quadVertices: [GLfloat] = [
            // positions(3) // normal(3)  // texcoords(2)  // tangent(3) // bitangent(3)
            pos1.x, pos1.y, pos1.z, nm.x, nm.y, nm.z, uv1.x, uv1.y, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
            pos2.x, pos2.y, pos2.z, nm.x, nm.y, nm.z, uv2.x, uv2.y, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
            pos3.x, pos3.y, pos3.z, nm.x, nm.y, nm.z, uv3.x, uv3.y, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
            
            pos1.x, pos1.y, pos1.z, nm.x, nm.y, nm.z, uv1.x, uv1.y, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z,
            pos3.x, pos3.y, pos3.z, nm.x, nm.y, nm.z, uv3.x, uv3.y, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z,
            pos4.x, pos4.y, pos4.z, nm.x, nm.y, nm.z, uv4.x, uv4.y, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z
        ]
        self.quadVertexObject = MyOpenGLVertexObject(vertices: quadVertices, alignment: [3,3,2,3,3])
    }
    
    func calculateTangentVector(edge1: GLKVector3, edge2: GLKVector3, deltaUV1: GLKVector2, deltaUV2: GLKVector2) -> GLKVector3 {
        let f: Float = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y)
        return GLKVector3Normalize(
            GLKVector3Make(
                deltaUV2.y * edge1.x - deltaUV1.y * edge2.x,
                deltaUV2.y * edge1.y - deltaUV1.y * edge2.y,
                deltaUV2.y * edge1.z - deltaUV1.y * edge2.z) * f)
    }
    
    func calculateBiTangentVector(edge1: GLKVector3, edge2: GLKVector3, deltaUV1: GLKVector2, deltaUV2: GLKVector2) -> GLKVector3 {
        let f: Float = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y)
        return GLKVector3Normalize(
            GLKVector3Make(
                -deltaUV2.x * edge1.x + deltaUV1.x * edge2.x,
                -deltaUV2.x * edge1.y + deltaUV1.x * edge2.y,
                -deltaUV2.x * edge1.z + deltaUV1.x * edge2.z) * f)
    }

    func prepareTexture() {
        self.diffuseMap = MyOpenGLTexture(imageName: "bricks2")
        self.normalMap = MyOpenGLTexture(imageName: "bricks2_normal")
        self.heightMap = MyOpenGLTexture(imageName: "bricks2_disp")
    }

    func render(_ bounds: NSRect) {
        let lightPos = GLKVector3Make(0.5, 1.0, 0.3)
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        glEnable(GLenum(GL_DEPTH_TEST))

        self.parallaxMappingProgram?.useProgramWith {
            (program) in
            let projection = GLKMatrix4MakePerspective(Float(45.0).radian, (Float(bounds.size.width / bounds.size.height)), 0.1, 100.0)
            let view = self.camera!.viewMatrix
            // let wallModel = GLKMatrix4MakeRotation(self.tick.radian, 1.0, 0.0, 1.0)
            let wallModel = GLKMatrix4MakeRotation(self.tick.radian, 0.0, 0.0, 1.0)

            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: view)
            program.setMat4(name: "model", value: wallModel)
            program.setVec3(name: "viewPos", value: camera!.position)
            program.setVec3(name: "lightPos", value: lightPos)

            program.setFloat(name: "heightScale", value: self.heightScale)

            program.setInt(name: "diffuseMap", value: 0)
            program.setInt(name: "normalMap", value: 1)
            program.setInt(name: "depthMap", value: 2)

            self.diffuseMap?.useTextureWith(target: GL_TEXTURE0) {
                self.normalMap?.useTextureWith(target: GL_TEXTURE1) {
                    self.heightMap?.useTextureWith(target: GL_TEXTURE2) {
                        self.quadVertexObject?.useVertexObjectWith {
                            (vertexObject) in
                            glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
                        }
                    }
                }
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST))
        self.tick += 1.0;
    }

    func dispose() {
        self.parallaxMappingProgram = nil
        self.diffuseMap = nil
        self.normalMap = nil
        self.heightMap = nil
        self.quadVertexObject = nil

    }

    func processKeyDown(keyCode: UInt16) {
        let gradient: Float = 0.01
        if keyCode == 12 { // 'Q'
            if self.heightScale > 0.0 {
                self.heightScale -= gradient
            }
            else {
                self.heightScale = 0.0
            }
        }
        else if keyCode == 14 { // 'E'
            if self.heightScale < 1.0 {
                self.heightScale += gradient
            }
            else {
                self.heightScale = 1.0
            }
        }
    }

}
