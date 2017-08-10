//
//  MyOpenGLMSAAFramebuffer.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 06/07/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLFramebuffer {
    let width, height: Int
    let multisamples: Int
    let textureFormat: Int32
    let framebufferAttachment: Int32

    var fbo: GLuint = 0
    var rbo: GLuint = 0
    var tex: GLuint = 0

    var valid: Bool = false

    var useMultisample: Bool {
        return self.multisamples > 0
    }
    var textureTarget: Int32 {
        return self.useMultisample ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D
    }

    convenience init(width: Int, height: Int) {
        self.init(width: width, height: height, multisamples: 0)
    }

    convenience init(width: Int, height: Int, multisamples: Int) {
        self.init(width: width, height: height, multisamples: multisamples, attachment: GL_COLOR_ATTACHMENT0, textureFormat: GL_RGB)
        self.setupRenderbuffer()
    }

    init(width: Int, height: Int, multisamples: Int, attachment: GLint, textureFormat: GLint) {
        self.width = width
        self.height = height
        self.multisamples = multisamples
        self.framebufferAttachment = attachment
        self.textureFormat = textureFormat

        self.setupTexture()
        self.setupFramebuffer()
    }

    func setupFramebuffer() {
        glGenFramebuffers(1, &self.fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)

        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(self.framebufferAttachment), GLenum(self.textureTarget), self.tex, 0)

        // now that we actually created the framebuffer and added add attachments we want to check if it is actually complete now
        self.valid = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE)
        if !valid {
            print("Error: Framebuffer is not complete!")
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func setupRenderbuffer() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)
        // create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
        glGenRenderbuffers(1, &self.rbo)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.rbo)

        if self.useMultisample {
            glRenderbufferStorageMultisample(GLenum(GL_RENDERBUFFER), GLsizei(self.multisamples), GLenum(GL_DEPTH24_STENCIL8), GLsizei(width), GLsizei(height))
        }
        else {
            glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), GLsizei(width), GLsizei(height)) // use a single renderbuffer object for both a depth and stencil buffer
        }
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_STENCIL_ATTACHMENT), GLenum(GL_RENDERBUFFER), self.rbo) // now actually attach it

        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func setupTexture() {
        // create a color attachment texture
        glGenTextures(1, &self.tex)
        glBindTexture(GLenum(self.textureTarget), self.tex)

        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

        if self.useMultisample {
            glTexImage2DMultisample(GLenum(GL_TEXTURE_2D_MULTISAMPLE), GLsizei(self.multisamples), self.textureFormat, GLsizei(self.width), GLsizei(self.height), GLboolean(GL_TRUE))
        }
        else {
            glTexImage2D(GLenum(self.textureTarget), 0, self.textureFormat, GLsizei(self.width), GLsizei(self.height), 0, GLenum(self.textureFormat), GLenum(GL_UNSIGNED_BYTE), nil)
        }

        glBindTexture(GLenum(self.textureTarget), 0)
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
