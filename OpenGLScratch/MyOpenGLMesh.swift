//
//  MyOpenGLMesh.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 01/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

struct Vertex {
    var position: GLKVector3
    var normal: GLKVector3
    var texCoords: GLKVector2
}

struct Texture {
    var id: GLint
    var type: String
}

class MyOpenGLMesh {
    var vertices: [Vertex]
    var indices: [GLuint]
    var textures: [Texture];

    var vao: GLuint = 0
    var vbo: GLuint = 0
    var ebo: GLuint = 0

    init(vertices: [Vertex], indices: [GLuint], textures: [Texture]) {
        self.vertices = vertices
        self.indices = indices
        self.textures = textures

        self.setupMesh()
    }

    func draw(program: MyOpenGLProgram) {
        var diffuseNr = 1
        var specularNr = 1

        for i in 0..<textures.count {
            glActiveTexture(GLenum(GL_TEXTURE0 + Int32(i))) // activate proper texture unit before binding
            // retrieve texture number (the N in diffuse_textureN)
            var number: String = ""
            let name = textures[i].type
            switch (name) {
                case "texture_diffuse":
                    number = String(diffuseNr)
                    diffuseNr += 1
                case "texture_specular":
                    number = String(specularNr)
                    specularNr += 1
            default:
                break;
            }
            program.setInt(name: "material." + name + number, value: GLint(i))
            glBindTexture(GLenum(GL_TEXTURE_2D), GLuint(textures[i].id))
        }
        glActiveTexture(GLenum(GL_TEXTURE0))

        // draw mesh
        glBindVertexArray(self.vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
        glBindVertexArray(0)
    }

    private func setupMesh() {
        glGenVertexArrays(1, &self.vao)
        glGenBuffers(1, &self.vbo)
        glGenBuffers(1, &self.ebo)

        glBindVertexArray(self.vao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)

        glBufferData(GLenum(GL_ARRAY_BUFFER), self.vertices.count * MemoryLayout<Vertex>.stride, self.vertices, GLenum(GL_STATIC_DRAW))

        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indices.count * MemoryLayout<GLuint>.stride, self.indices, GLenum(GL_STATIC_DRAW))

        // vertex positions
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), nil)
        // vertex normals
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLKVector3>.stride))
        // vertex texture coords
        glEnableVertexAttribArray(2)
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), MyOpenGLUtils.BUFFER_OFFSET(MemoryLayout<GLKVector3>.stride * 2))

        glBindVertexArray(0)
    }
}
