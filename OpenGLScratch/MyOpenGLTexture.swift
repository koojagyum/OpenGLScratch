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

    public init(image: CGImage) {
        let width = image.width
        let height = image.height

        guard((width > 0) && (height > 0)) else {
            fatalError("Tried to pass in a zero-sized image")
        }

        var dataFromImageDataProvider:CFData!
        var imageData:UnsafeMutablePointer<GLubyte>!
        let format = GL_RGBA

        dataFromImageDataProvider = image.dataProvider?.data
        imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider)!)

        var texture: GLuint = 0
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)

        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(format), GLenum(GL_UNSIGNED_BYTE), imageData)
        glGenerateMipmap(GLenum(GL_TEXTURE_2D))

        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        self.textureId = texture
    }

    public convenience init(image: NSImage) {
        self.init(image: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    }

    public convenience init(imageName: String) {
        guard let image = NSImage(named:imageName) else {
            fatalError("No such image named: \(imageName) in your application bundle")
        }
        self.init(image: image)
    }

    deinit {
        var textureIdToDelete = self.textureId
        glDeleteTextures(1, &textureIdToDelete);
    }
}
