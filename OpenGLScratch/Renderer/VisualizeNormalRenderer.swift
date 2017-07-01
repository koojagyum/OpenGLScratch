//
//  VisualizeNormalRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 01/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit
import OpenGL.GL3

class VisualizeNormalRenderer: MyOpenGLRendererDelegate {
    var camera: MyOpenGLCamera?
    var renderInterval: Double {
        return 0.0
    }

    var modelProgram: MyOpenGLProgram?
    var normalProgram: MyOpenGLProgram?

    var model: MyOpenGLModel?

    func prepare() {
        self.prepareProgram()
        self.model = MyOpenGLModel(path: "/Users/koodev/Workspace/Resource/nanosuit/nanosuit.obj")
    }

    func prepareProgram() {
        self.modelProgram = MyOpenGLUtils.createProgramWithNames(vshName: "Model", fshName: "Model")
        self.normalProgram = MyOpenGLUtils.createProgramWithNames(vshName: "VisualizeNormal", fshName: "Yellow", gshName: "VisualizeNormal")
    }

    func render(_ bounds: NSRect) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))

        let drawingBlock: (MyOpenGLProgram) -> () = {
            (program) in
            let projection = GLKMatrix4MakePerspective(MyOpenGLUtils.DEGREE2RADIAN(45.0), (Float(bounds.size.width / bounds.size.height)), 1.0, 100.0)
            let model = GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0, -1.75, 0.0), 0.2, 0.2, 0.2)
            program.setMat4(name: "projection", value: projection)
            program.setMat4(name: "view", value: (self.camera?.viewMatrix)!)
            program.setMat4(name: "model", value: model)

            if let m = self.model {
                m.draw(program: program)
            }
        }

        self.modelProgram?.useProgramWith(block: drawingBlock)
        self.normalProgram?.useProgramWith(block: drawingBlock)

        glDisable(GLenum(GL_DEPTH_TEST))
    }

    func dispose() {
        self.modelProgram = nil
        self.normalProgram = nil
        self.model = nil
    }
}
