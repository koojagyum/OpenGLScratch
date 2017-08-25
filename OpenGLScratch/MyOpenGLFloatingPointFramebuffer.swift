//
//  MyOpenGLFloatingPointFramebuffer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 09/08/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class MyOpenGLFloatingPointFramebuffer: MyOpenGLFramebuffer {
    init(width: Int, height: Int) {
        super.init(width: width, height: height, multisamples: 0, attachment: GL_COLOR_ATTACHMENT0, textureFormat: GL_RGB, textureTarget: GL_TEXTURE_2D)
        self.setupRenderbuffer() // Poor code!

        self.texture.useTextureWith {
            glTexImage2D(GLenum(self.textureTarget), 0, GL_RGBA16F, GLsizei(self.width), GLsizei(self.height), 0, GLenum(self.textureFormat), GLenum(GL_FLOAT), nil)
        }
    }
}
