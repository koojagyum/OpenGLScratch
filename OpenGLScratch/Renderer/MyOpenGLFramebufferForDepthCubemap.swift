//
//  MyOpenGLFramebufferForDepthCubemap.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 20/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLFramebufferForDepthCubemap: MyOpenGLFramebuffer {
    override var textureTarget: Int32 {
        return GL_TEXTURE_CUBE_MAP
    }

    init(width: Int, height: Int) {
        super.init(width: width, height: height, multisamples: 0, attachment: GL_DEPTH_ATTACHMENT, textureFormat: GL_DEPTH_COMPONENT)
    }

    override func setupTexture() {
        glGenTextures(1, &self.tex)
        glBindTexture(GLenum(self.textureTarget), self.tex)

        for i in 0...5 {
            glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_POSITIVE_X+Int32(i)), 0, self.textureFormat, GLsizei(width), GLsizei(height), 0, GLenum(self.textureFormat), GLenum(GL_FLOAT), nil)
        }

        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_R), GL_CLAMP_TO_EDGE)

        glBindTexture(GLenum(self.textureTarget), 0)
    }

    override func setupFramebuffer() {
        glGenFramebuffers(1, &self.fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)

        glFramebufferTexture(GLenum(GL_FRAMEBUFFER), GLenum(self.framebufferAttachment), self.tex, 0)

        glDrawBuffer(GLenum(GL_NONE))
        glReadBuffer(GLenum(GL_NONE))

        // now that we actually created the framebuffer and added add attachments we want to check if it is actually complete now
        self.valid = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE)
        if !valid {
            print("Error: Framebuffer is not complete!")
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

}
