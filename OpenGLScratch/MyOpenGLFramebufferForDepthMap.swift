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
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_BORDER)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_BORDER)

        let borderColor: [GLfloat] = [1.0, 1.0, 1.0, 1.0]
        glTexParameterfv(GLenum(self.textureTarget), GLenum(GL_TEXTURE_BORDER_COLOR), borderColor)

        glBindTexture(GLenum(self.textureTarget), 0)
    }
}
