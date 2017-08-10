//
//  MyOpenGLView.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 2017. 3. 8..
//  Copyright © 2017년 Jagyum Koo. All rights reserved.
//

import Cocoa
import Foundation.NSTimer
import GLKit
import OpenGL.GL

protocol MyOpenGLRendererDelegate {
    var renderInterval: Double { get }
    var camera: MyOpenGLCamera? { get set }
    func prepare()
    func render(_ bounds:NSRect)
    func dispose()
}

protocol MyOpenGLKeyConsumable {
    func processKeyDown(keyCode: UInt16)
}

class MyOpenGLView : NSOpenGLView {
    private weak var currentTimer: Timer?
    private var _renderer: MyOpenGLRendererDelegate?
    let camera = MyOpenGLCamera(position: GLKVector3Make(0.0, 0.0, 3.0), worldUp: GLKVector3Make(0.0, 1.0, 0.0))
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
            self.camera.reset(position: GLKVector3Make(0.0, 0.0, 3.0), worldUp: GLKVector3Make(0.0, 1.0, 0.0))
            _renderer?.camera = self.camera

            // HDRRenderer requires its own camera direction
            if let _ = _renderer as? HDRRenderer {
                self.camera.yaw = 90.0;
            }

            if let interval = _renderer?.renderInterval, interval > 0 {
                let view = self
                self.currentTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
                    timer in
                    if timer != self.currentTimer {
                        timer.invalidate()
                    }
                    else if let currentInterval = self.renderer?.renderInterval {
                        if currentInterval > 0 {
                            view.needsDisplay = true
                        }
                        else {
                            timer.invalidate()
                        }
                    }
                }
            }
        }
    }
    var polygonMode: String = "FILL"

    override func draw(_ dirtyRect: NSRect) {
        guard let context = self.openGLContext else {
            return
        }
        context.makeCurrentContext()

        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        if let renderer = self.renderer {
            self.setupPolygonMode()
            renderer.render(self.bounds)
        }

        context.flushBuffer()
    }

    override func awakeFromNib() {
        let pixelFormatAttributes:[NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile),
            NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion4_1Core),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 24,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAStencilSize), 8,
            // NSOpenGLPixelFormatAttribute(NSOpenGLPFAMultisample),
            // NSOpenGLPixelFormatAttribute(NSOpenGLPFASampleBuffers), 1,
            // NSOpenGLPixelFormatAttribute(NSOpenGLPFASamples), 4,
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

    private func setupPolygonMode() {
        var mode = GL_LINE
        switch (self.polygonMode) {
            case "FILL":
                mode = GL_FILL
            case "LINE":
                mode = GL_LINE
            case "POINT":
                mode = GL_POINT
                glPointSize(5.0)
        default:
            mode = GL_FILL
        }
        glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(mode))
    }

    override func keyDown(with event: NSEvent) {
        if let keyConsumable = self.renderer as? MyOpenGLKeyConsumable {
            keyConsumable.processKeyDown(keyCode: event.keyCode)
        }
        camera.processKeyboard(MyOpenGLUtils.keyCodeToMovement(keyCode: event.keyCode), 0.1)
        self.redraw()
    }

    override func mouseDragged(with event: NSEvent) {
        camera.processMouseMovement(GLfloat(event.deltaX), GLfloat(event.deltaY), true)
        self.redraw()
    }

    override var acceptsFirstResponder: Bool { return true }

    func redraw() {
        if let interval = _renderer?.renderInterval, interval == 0 {
            self.needsDisplay = true
        }
    }
}
