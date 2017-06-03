//
//  MyOpenGLModel.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 02/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

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

        for assimpMesh in (loader.meshes.map { $0 as! MyAssimpMesh }) {
//            var vertices: [Vertex] = []
//            let assimpVertices = assimpMesh.vertices.map { $0.myAssimpVertexValue }
//
//            for assimpVertex in assimpVertices {
//                let vertex = Vertex(position: assimpVertex.position, normal: assimpVertex.normal, texCoords: assimpVertex.texCoords)
//                vertices.append(vertex)
//            }

            let vertices = (assimpMesh.vertices.map { $0.myAssimpVertexValue }).map {
                (assimpVertx) -> Vertex in
                return Vertex(position: assimpVertx.position, normal: assimpVertx.normal, texCoords: assimpVertx.texCoords)
            }
            let indices = (assimpMesh.indices.map { $0 as! NSNumber }).map { $0.uint32Value }

            self.meshes.append(MyOpenGLMesh(vertices: vertices, indices: indices, textures: []))
        }
    }
}
