//
//  MyOpenGLTexture.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 12/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import AppKit
import Foundation
import OpenGL.GL3

class MyOpenGLTexture {
    let textureId: GLuint
    let textureTarget: Int32

    init(textureTarget: Int32) {
        var texture: GLuint = 0
        glGenTextures(1, &texture)

        self.textureId = texture
        self.textureTarget = textureTarget
    }

    convenience init?(image: CGImage, textureTarget: Int32, gammaCorrection: Bool) {
        let width = image.width
        let height = image.height

        guard((width > 0) && (height > 0)) else {
            fatalError("Tried to pass in a zero-sized image")
            return nil
        }

        var dataFromImageDataProvider:CFData!

        var dataFormat: Int32
        var internalFormat: Int32

        let numberOfComponents = image.colorSpace!.numberOfComponents
        switch numberOfComponents {
        case 1:
            internalFormat = GL_RED
            dataFormat = GL_RED
        case 3:
            internalFormat = gammaCorrection ? GL_SRGB : GL_RGB
            dataFormat = GL_RGBA
        case 4:
            internalFormat = gammaCorrection ? GL_SRGB_ALPHA : GL_RGBA
            dataFormat = GL_RGBA
        default:
            internalFormat = gammaCorrection ? GL_SRGB : GL_RGB
            dataFormat = GL_RGBA
        }

        dataFromImageDataProvider = image.dataProvider?.data
        let imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider)!)

        self.init(textureTarget: textureTarget)
        self.useTextureWith {
            glTexImage2D(GLenum(textureTarget), 0, internalFormat, GLsizei(width), GLsizei(height), 0, GLenum(dataFormat), GLenum(GL_UNSIGNED_BYTE), imageData)
            glGenerateMipmap(GLenum(textureTarget))
        }
    }

    public convenience init?(image: CGImage, gammaCorrection: Bool) {
        self.init(image: image, textureTarget: GL_TEXTURE_2D, gammaCorrection: gammaCorrection)
    }

    public convenience init?(image: NSImage, gammaCorrection: Bool) {
        self.init(image: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, gammaCorrection: gammaCorrection)
    }

    public convenience init?(imageName: String) {
        guard let image = NSImage(named:imageName) else {
            fatalError("No such image named: \(imageName) in your application bundle")
            return nil
        }
        self.init(image: image, gammaCorrection: false)
    }

    public convenience init?(imageName: String, gammaCorrection: Bool) {
        guard let image = NSImage(named:imageName) else {
            fatalError("No such image named: \(imageName) in your application bundle")
            return nil
        }
        self.init(image: image, gammaCorrection: gammaCorrection)
    }

    public convenience init?(path: String) {
        guard let image = NSImage(contentsOfFile: path) else {
            fatalError("No such image in path: \(path)")
            return nil
        }
        self.init(image: image, gammaCorrection: false)
    }

    deinit {
        var textureIdToDelete = self.textureId
        glDeleteTextures(1, &textureIdToDelete);
    }

    func useTextureWith(block: () -> ()) {
        glBindTexture(GLenum(self.textureTarget), self.textureId)
        block()
        glBindTexture(GLenum(self.textureTarget), 0)
    }

    func useTextureWith(target: Int32, block: () -> ()) {
        glActiveTexture(GLenum(target))
        glBindTexture(GLenum(self.textureTarget), self.textureId)
        block()
        glActiveTexture(GLenum(target))
        glBindTexture(GLenum(self.textureTarget), 0)
    }
}
