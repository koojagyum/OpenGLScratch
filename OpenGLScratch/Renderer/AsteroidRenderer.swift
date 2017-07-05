//
//  AsteroidRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 01/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class AsteroidRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera? {
        didSet {
            self.camera?.reset(position: GLKVector3Make(0.0, 0.0, 155.0), worldUp: GLKVector3Make(0.0, 1.0, 0.0))
        }
    }
    var renderInterval: Double {
        return 0.0
    }

    var planetProgram: MyOpenGLProgram?
    var planetModel: MyOpenGLModel?
    var asteroidProgram: MyOpenGLProgram?
    var rockModel: MyOpenGLModel?

    let asteroidsAmount = 10000
    var vboForInstancedArray: GLuint = 0

    private var generateDisplacement: Float {
        // [-offset, offset]: -25.00 ~ +24.99
        let offset: Float = 25.0
        let displacement = Float(arc4random_uniform(UInt32(2 * offset * 100))) / 100.0 - offset
        return displacement
    }

    private var generateScale: Float {
        // 0.05 ~ 0.25
        return Float(arc4random_uniform(20)) / 100.0 + 0.05
    }

    private var generateRotAngle: Float {
        // randomly picked rotation axis vector
        return Float(arc4random_uniform(360)).radian
    }

    func prepare() {
        self.prepareProgram()
        self.planetModel = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/Planet/planet.obj")
        self.rockModel = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/Rock/rock.obj")

        // generate a large list of semi-random model transformation matrices
        var modelMatrices = [GLKMatrix4]()
        let radius: Float = 150.0

        for i in 0..<self.asteroidsAmount {
            let angle = Float(i) / Float(self.asteroidsAmount) * Float(360.0).radian
            let x = sin(angle) * radius + self.generateDisplacement
            let y = self.generateDisplacement * 0.4 // keep height of asteroid field smaller compared to width of x and z
            let z = cos(angle) * radius + self.generateDisplacement
            let scale = self.generateScale
            let rotAngle = self.generateRotAngle
            let model = GLKMatrix4Rotate(GLKMatrix4Scale(GLKMatrix4MakeTranslation(x, y, z), scale, scale, scale), rotAngle, 0.4, 0.6, 0.8)

            modelMatrices.append(model)
        }

        // configure instanced array
        glGenBuffers(1, &self.vboForInstancedArray)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vboForInstancedArray)
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.asteroidsAmount * MemoryLayout<GLKMatrix4>.stride, modelMatrices, GLenum(GL_STATIC_DRAW))

        // set transformation matrices as an instance vertex attribut (with divisor 1)
        // note: we're creating a little by taking the, now publicly declared, VAO of the model's mesh(es) and adding new vertexAttribPointers
        // normally you'd want to do this in a more organized fashion, but for learning purposes this will do.
        _ = self.rockModel?.meshes.map {
            (mesh) in
            mesh.vertexObject?.useVertexObjectWith {
                (vertexObject) in
                let attribIndex = GLuint(vertexObject.attributeCount)
                let mat4Stride = MemoryLayout<GLKMatrix4>.stride
                let vec4Stride = mat4Stride / 4

                glEnableVertexAttribArray(attribIndex+0)
                glVertexAttribPointer(attribIndex+0, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(mat4Stride), MyOpenGLUtils.BUFFER_OFFSET(vec4Stride * 0))
                glEnableVertexAttribArray(attribIndex+1)
                glVertexAttribPointer(attribIndex+1, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(mat4Stride), MyOpenGLUtils.BUFFER_OFFSET(vec4Stride * 1))
                glEnableVertexAttribArray(attribIndex+2)
                glVertexAttribPointer(attribIndex+2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(mat4Stride), MyOpenGLUtils.BUFFER_OFFSET(vec4Stride * 2))
                glEnableVertexAttribArray(attribIndex+3)
                glVertexAttribPointer(attribIndex+3, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(mat4Stride), MyOpenGLUtils.BUFFER_OFFSET(vec4Stride * 3))

                glVertexAttribDivisor(attribIndex+0, 1)
                glVertexAttribDivisor(attribIndex+1, 1)
                glVertexAttribDivisor(attribIndex+2, 1)
                glVertexAttribDivisor(attribIndex+3, 1)
            }
        }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }

    func prepareProgram() {
        self.planetProgram = MyOpenGLUtils.createProgramWithName(name: "Model")
        self.asteroidProgram = MyOpenGLUtils.createProgramWithName(name: "Asteroid")
    }

    func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 1000.0)

        self.planetProgram?.useProgramWith {
            (program) in
            let model = GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, -3.0, 0.0), 4.0, 4.0, 4.0)
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: (self.camera?.viewMatrix)!)
            program.setMat4(name: "model", value: model)

            if let m = self.planetModel {
                m.draw(program: program)
            }
        }

        self.asteroidProgram?.useProgramWith {
            (program) in
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: (self.camera?.viewMatrix)!)
            program.setInt(name: "texture_diffuse1", value: 0)

            // glActiveTexture(GLenum(GL_TEXTURE0))
            _ = self.rockModel?.meshes.map {
                (mesh) in
                mesh.textures[0].texture?.useTextureWith {
                    mesh.vertexObject?.useVertexObjectWith {
                        (vertexObject) in
                        glDrawElementsInstanced(GLenum(GL_TRIANGLES), GLsizei(vertexObject.count), GLenum(GL_UNSIGNED_INT), nil, GLsizei(self.asteroidsAmount))
                    }
                }
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.planetProgram = nil
        self.planetModel = nil
        self.rockModel = nil
        glDeleteBuffers(1, &self.vboForInstancedArray)
    }
}
