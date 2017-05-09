//
//  MyOpenGLView.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 2017. 3. 8..
//  Copyright © 2017년 Jagyum Koo. All rights reserved.
//

import Cocoa
import OpenGL.GL

protocol MyOpenGLRendererDelegate {
    func prepare()
    func render()
    func dispose()
}

class MyOpenGLView : NSOpenGLView {
    private var _renderer: MyOpenGLRendererDelegate?
    var renderer: MyOpenGLRendererDelegate? {
        get {
            return self._renderer
        }
        set {
            guard let context = self.openGLContext else {
                return
            }
            context.makeCurrentContext()
            _renderer?.dispose()
            _renderer = newValue
            _renderer?.prepare()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = self.openGLContext else {
            return
        }
        guard let renderer = self.renderer else {
            return
        }
        context.makeCurrentContext()
        renderer.render()
        context.flushBuffer()
    }

    override func awakeFromNib() {
        let pixelFormatAttributes:[NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile),
            NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion4_1Core),
            0
        ]

        guard let pixelFormat = NSOpenGLPixelFormat(attributes:pixelFormatAttributes) else {
            fatalError("No appropriate pixel format found when creating OpenGL context.")
        }
        // TODO: Take into account the sharegroup
        guard let generatedContext = NSOpenGLContext(format:pixelFormat, share:nil) else {
            fatalError("Unable to create an OpenGL context. The GPUImage framework requires OpenGL support to work.")
        }

        self.openGLContext = generatedContext
        self.pixelFormat = pixelFormat
    }
}
