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
        super.init(width: width, height: height, multisamples: 0, attachment: GL_COLOR_ATTACHMENT0, textureFormat: GL_RGB)
        self.setupRenderbuffer() // Poor code!

        glBindTexture(GLenum(self.textureTarget), self.tex)

        glTexImage2D(GLenum(self.textureTarget), 0, GL_RGBA16F, GLsizei(self.width), GLsizei(self.height), 0, GLenum(self.textureFormat), GLenum(GL_FLOAT), nil)

        glBindTexture(GLenum(self.textureTarget), 0)
    }
}
