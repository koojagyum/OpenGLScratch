//
//  MyOpenGLFramebufferObject.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 05/09/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLFramebufferObject {
    let width, height: Int
    var fbo: GLuint = 0
    var rbo: GLuint = 0

    var attachments = [Int32: MyOpenGLTexture]()
    var valid = false

    init(width: Int, height: Int) {
        self.width = width
        self.height = height

        self.setupFbo()
        self.setupRbo()
        self.setupAttachment()
    }

    private func setupFbo() {
        glGenFramebuffers(1, &self.fbo)
    }

    private func setupAttachment() {
        let texture = MyOpenGLTexture(textureTarget: GL_TEXTURE_2D)
        texture.useTextureWith {
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, GLsizei(self.width), GLsizei(self.height), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)
        }
        self.attach(texture: texture, attachment: GL_COLOR_ATTACHMENT0)
    }

    private func setupRbo() {
        self.useFbo {
            glGenRenderbuffers(1, &self.rbo)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.rbo)
            glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), GLsizei(self.width), GLsizei(self.height))
            glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_STENCIL_ATTACHMENT), GLenum(GL_RENDERBUFFER), self.rbo)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)
        }
    }

    func checkFbo() -> Bool {
        self.useFbo {
            self.valid = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE)
        }
        return self.valid
    }

    func useFbo(block: () -> ()) {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)
        block()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func attach(texture: MyOpenGLTexture, attachment: Int32) {
        self.useFbo {
            attachments[attachment] = texture
            glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(attachment), GLenum(texture.textureTarget), texture.textureId, 0)
        }
    }

    func draw(block: () -> ()) -> MyOpenGLTexture? {
        var previousViewport: [GLint] = [0, 0, 1, 1]
        glGetIntegerv(GLenum(GL_VIEWPORT), &previousViewport)
        glViewport(0, 0, GLsizei(self.width), GLsizei(self.height))

        self.useFbo { block() }

        glViewport(previousViewport[0], previousViewport[1], previousViewport[2], previousViewport[3])

        return attachments[GL_COLOR_ATTACHMENT0]
    }

    deinit {
        glDeleteFramebuffers(1, &self.fbo)
        glDeleteRenderbuffers(1, &self.rbo)
    }
}
