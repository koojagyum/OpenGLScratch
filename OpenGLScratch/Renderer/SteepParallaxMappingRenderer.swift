//
//  SteepParallaxMappingRenderer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 07/08/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class SteepParallaxMappingRenderer: ParallaxMappingRenderer {
    override var renderInterval: Double {
        return 0.0 // 1.0/60.0
    }

    override func prepareProgram() {
        self.parallaxMappingProgram = MyOpenGLUtils.createProgramWithNames(vshName: "ParallaxMapping", fshName: "SteepParallaxMapping")
    }

    override func prepareTexture() {
        // self.diffuseMap = MyOpenGLTexture(imageName: "bricks2")
        // self.normalMap = MyOpenGLTexture(imageName: "bricks2_normal")
        // self.heightMap = MyOpenGLTexture(imageName: "bricks2_disp")
        self.diffuseMap = MyOpenGLTexture(imageName: "wood")
        self.normalMap = MyOpenGLTexture(imageName: "toy_box_normal")
        self.heightMap = MyOpenGLTexture(imageName: "toy_box_disp")
    }

}
