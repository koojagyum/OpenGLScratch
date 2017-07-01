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
    var id: GLuint {
        get {
            return texture!.textureId
        }
    }
    var type: String
    var texture: MyOpenGLTexture?
}

class MyOpenGLMesh {
    var vertexObject: MyOpenGLVertexObject?
    var textures: [Texture]

    init(vertices: [Vertex], indices: [GLuint], textures: [Texture]) {
        self.textures = textures
        self.setupVertices(vertices: vertices, indices: indices)
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
        self.vertexObject?.useVertexObjectWith {
            (vertexObject) in
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(vertexObject.count), GLenum(GL_UNSIGNED_INT), nil)
        }
    }

    func setupVertices(vertices: [Vertex], indices: [GLuint]) {
        var rawVertices = [GLfloat]()
        for v in vertices {
            rawVertices += v.position.array
            rawVertices += v.normal.array
            rawVertices += v.texCoords.array
        }
        self.vertexObject = MyOpenGLVertexObject(vertices: rawVertices, alignment: [3, 3, 2], indices: indices)
    }

    func checkGlError(_ message: String) {
        print("\(message): \(glGetError())")
    }
}
