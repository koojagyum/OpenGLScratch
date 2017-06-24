//
//  MyOpenGLCubemapTexture.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 24/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import AppKit
import Foundation
import OpenGL.GL3

class MyOpenGLCubemapTexture: MyOpenGLTexture {
    init?(facePaths: [String]) {
        if facePaths.count != 6 {
            print("Cubemap texture requires 6 faces")
            return nil
        }

        super.init(textureTarget: GL_TEXTURE_CUBE_MAP)
        self.useTextureWith {
            _ = facePaths.enumerated().map {
                (index, path) in
                print("Texture loading index: \(index), path: \(path)")

                guard let nsImage = NSImage(contentsOfFile: path), let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    fatalError("Failed to load an image")
                }

                let width = cgImage.width
                let height = cgImage.height

                guard((width > 0) && (height > 0)) else {
                    fatalError("Tried to pass in a zero-sized image")
                }

                var dataFromImageDataProvider:CFData!

                dataFromImageDataProvider = cgImage.dataProvider?.data
                let imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider)!)

                glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_POSITIVE_X + Int32(index)), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
            }

            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(self.textureTarget), GLenum(GL_TEXTURE_WRAP_R), GL_CLAMP_TO_EDGE)
        }
    }

    convenience init?(image: CGImage, textureTarget: Int32) {
        // Not allowed to use!
        return nil
    }

    func imageDataFrom(path: String) -> (UnsafeMutablePointer<GLubyte>?, Int, Int) {
        guard let nsImage = NSImage(contentsOfFile: path), let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Failed to load an image")
        }

        let width = cgImage.width
        let height = cgImage.height

        guard((width > 0) && (height > 0)) else {
            fatalError("Tried to pass in a zero-sized image")
        }

        var dataFromImageDataProvider:CFData!
        var imageData:UnsafeMutablePointer<GLubyte>!

        dataFromImageDataProvider = cgImage.dataProvider?.data
        imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider)!)

        return (imageData, width, height)
    }
    
    func imageDataFrom(image: NSImage) -> (UnsafeMutablePointer<GLubyte>?, Int, Int) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Failed to load an image")
        }

        let width = cgImage.width
        let height = cgImage.height

        guard((width > 0) && (height > 0)) else {
            fatalError("Tried to pass in a zero-sized image")
        }

        var dataFromImageDataProvider:CFData!
        var imageData:UnsafeMutablePointer<GLubyte>!

        dataFromImageDataProvider = cgImage.dataProvider?.data
        imageData = UnsafeMutablePointer<GLubyte>(mutating:CFDataGetBytePtr(dataFromImageDataProvider)!)

        return (imageData, width, height)
    }
}
