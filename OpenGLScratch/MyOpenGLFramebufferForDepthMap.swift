//
//  MyOpenGLFramebufferForDepthMap.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 17/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLFramebufferForDepthMap: MyOpenGLFramebuffer {
    init(width: Int, height: Int) {
        super.init(width: width, height: height, multisamples: 0, attachment: GL_DEPTH_ATTACHMENT, textureFormat: GL_DEPTH_COMPONENT)

        glBindTexture(GLenum(self.textureTarget), self.tex)
        glTexImage2D(GLenum(self.textureTarget), 0, self.textureFormat, GLsizei(width), GLsizei(height), 0, GLenum(self.textureFormat), GLenum(GL_FLOAT), nil)
        glBindTexture(GLenum(self.textureTarget), 0)
    }
}
