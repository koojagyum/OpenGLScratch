//
//  AsteroidRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 01/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class AsteroidRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var planetProgram: MyOpenGLProgram?
    var planetModel: MyOpenGLModel?

    func prepare() {
        self.prepareProgram()
        self.planetModel = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/Planet/planet.obj")
    }

    func prepareProgram() {
        self.planetProgram = MyOpenGLUtils.createProgramWithNames(vshName: "Model", fshName: "Model")
    }

    func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        self.planetProgram?.useProgramWith {
            (program) in
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            let model = GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, 0.0, 0.0), 0.2, 0.2, 0.2)
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: (self.camera?.viewMatrix)!)
            program.setMat4(name: "model", value: model)

            if let m = self.planetModel {
                m.draw(program: program)
            }
        }

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.planetProgram = nil
        self.planetModel = nil
    }
}
