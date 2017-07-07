//
//  MyOpenGLMSAAFramebuffer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 06/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLMSAAFramebuffer {
    var fbo: GLuint = 0
    var rbo: GLuint = 0
    var tex: GLuint = 0
    var width, height: Int
    var multisample: Bool
    var multisampleNumber: Int

    var valid: Bool

    var textureTarget: Int32 {
        if self.multisample {
            return GL_TEXTURE_2D_MULTISAMPLE
        }
        return GL_TEXTURE_2D
    }

    init(width: Int, height: Int, multisample: Bool, multisampleNumber: Int) {
        self.width = width
        self.height = height
        self.multisample = multisample
        self.multisampleNumber = multisampleNumber

        glGenFramebuffers(1, &self.fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)

        // create a color attachment texture
        glGenTextures(1, &self.tex)

        if self.multisample {
            glBindTexture(GLenum(GL_TEXTURE_2D_MULTISAMPLE), self.tex)
            glTexImage2DMultisample(GLenum(GL_TEXTURE_2D_MULTISAMPLE), GLsizei(self.multisampleNumber), GL_RGB, GLsizei(width), GLsizei(height), GLboolean(GL_TRUE))
            glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D_MULTISAMPLE), self.tex, 0)
        }
        else {
            glBindTexture(GLenum(GL_TEXTURE_2D), self.tex)
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)
            glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), self.tex, 0)
        }

        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

        // create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
        glGenRenderbuffers(1, &self.rbo)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.rbo)

        if self.multisample {
            glRenderbufferStorageMultisample(GLenum(GL_RENDERBUFFER), GLsizei(self.multisampleNumber), GLenum(GL_DEPTH24_STENCIL8), GLsizei(width), GLsizei(height))
        }
        else {
            glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), GLsizei(width), GLsizei(height)) // use a single renderbuffer object for both a depth and stencil buffer
        }
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
