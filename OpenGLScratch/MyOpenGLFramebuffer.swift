//
//  MyOpenGLFramebuffer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 21/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLFramebuffer {
    var fbo: GLuint = 0
    var rbo: GLuint = 0
    var tex: GLuint = 0
    var width, height: Int

    var valid: Bool

    init(width: Int, height: Int) {
        self.width = width
        self.height = height

        glGenFramebuffers(1, &self.fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)

        // create a color attachment texture
        glGenTextures(1, &self.tex)
        glBindTexture(GLenum(GL_TEXTURE_2D), self.tex)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), self.tex, 0)

        // create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
        glGenRenderbuffers(1, &self.rbo)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.rbo)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), GLsizei(width), GLsizei(height)) // use a single renderbuffer object for both a depth and stencil buffer
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_STENCIL_ATTACHMENT), GLenum(GL_RENDERBUFFER), self.rbo) // now actually attach it

        // now that we actually created the framebuffer and added add attachments we want to check if it is actually complete now
        self.valid = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE)
        if !valid {
            print("Error: Framebuffer is not complete!")
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }

    func draw(block: () -> ()) -> GLuint {
        var previousViewport: [GLint] = [0, 0, 1, 1]
        glGetIntegerv(GLenum(GL_VIEWPORT), &previousViewport)
        glViewport(0, 0, GLsizei(self.width), GLsizei(self.height))

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)
        block()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)

        glViewport(previousViewport[0], previousViewport[1], previousViewport[2], previousViewport[3])
        return self.tex
    }

    deinit {
        glDeleteFramebuffers(1, &self.fbo)
        glDeleteTextures(1, &self.tex)
        glDeleteRenderbuffers(1, &self.rbo)
    }
}
