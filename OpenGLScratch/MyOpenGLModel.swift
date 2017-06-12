//
//  MyOpenGLModel.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 02/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

extension MyAssimpTextureType {
    var typeString: String {
        switch (self) {
        case MyAssimpTextureType_Specular:
            return "texture_specular"
        case MyAssimpTextureType_Diffuse:
            return "texture_diffuse"
        default: break
        }
        return ""
    }
}

class MyOpenGLModel {
    var meshes: [MyOpenGLMesh] = []
    var directory: String = ""

    init(path: String) {
        self.loadModel(path: path)
    }

    func draw(program: MyOpenGLProgram) {
        for mesh in self.meshes {
            mesh.draw(program: program)
        }
    }

    func loadModel(path: String) {
        let loader = MyAssimpLoader()
        loader.loadModel(path)

        let directory = (path as NSString).deletingLastPathComponent
        for assimpMesh in (loader.meshes.map { $0 as! MyAssimpMesh }) {
            let vertices = (assimpMesh.vertices.map { $0.myAssimpVertexValue }).map {
                (assimpVertx) -> Vertex in
                return Vertex(position: assimpVertx.position, normal: assimpVertx.normal, texCoords: assimpVertx.texCoords)
            }
            let indices = (assimpMesh.indices.map { $0 as! NSNumber }).map { $0.uint32Value }
            let textures = assimpMesh.textures.map {
                (assimpTextureInfo) -> Texture in
                let texturePath = (directory + "/" + assimpTextureInfo.filename).replacingOccurrences(of: "\\", with: "/")
                return Texture(type: assimpTextureInfo.type.typeString, texture: MyOpenGLTexture(path: texturePath))
            }

            self.meshes.append(MyOpenGLMesh(vertices: vertices, indices: indices, textures: textures))
        }
    }
}
