//
//  MyOpenGLFloatingPointFramebufferMultiTarget.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 12/08/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation

class MyOpenGLFloatingPointFramebufferMultiTarget: MyOpenGLFramebuffer {
    var tex1: GLuint {
        get {
            return self.texture1.textureId;
        }
    }
    var tex2: GLuint {
        get {
            return self.texture2.textureId
        }
    }

    var texture1: MyOpenGLTexture {
        get {
            return self.texture
        }
    }
    let texture2: MyOpenGLTexture = MyOpenGLTexture(textureTarget: GL_TEXTURE_2D)

    init(width: Int, height: Int) {
        super.init(width: width, height: height, multisamples: 0, attachment: GL_COLOR_ATTACHMENT0, textureFormat: GL_RGB, textureTarget: GL_TEXTURE_2D)
        self.setupRenderbuffer() // Poor code!
    }

    override func setupTexture() {
        self.texture1.useTextureWith {
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            glTexImage2D(GLenum(self.textureTarget), 0, GL_RGBA16F, GLsizei(self.width), GLsizei(self.height), 0, GLenum(self.textureFormat), GLenum(GL_FLOAT), nil)
        }

        self.texture2.useTextureWith {
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            glTexImage2D(GLenum(self.textureTarget), 0, GL_RGBA16F, GLsizei(self.width), GLsizei(self.height), 0, GLenum(self.textureFormat), GLenum(GL_FLOAT), nil)
        }
    }

    override func setupFramebuffer() {
        glGenFramebuffers(1, &self.fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)

        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(self.textureTarget), self.tex1, 0)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT1), GLenum(self.textureTarget), self.tex2, 0)

        let attachments: [GLenum] = [GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_COLOR_ATTACHMENT1)]
        glDrawBuffers(2, attachments)

        self.valid = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE)
        if !valid {
            print("Error: Framebuffer is not complete!")
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    override func setupRenderbuffer() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.fbo)

        glGenRenderbuffers(1, &self.rbo)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.rbo)

        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT), GLsizei(self.width), GLsizei(self.height))
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), self.rbo)

        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }
}
