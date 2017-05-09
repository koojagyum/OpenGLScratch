//
//  MyOpenGLProgram.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 09/05/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import OpenGL.GL3

class MyOpenGLProgram {

    enum ProgramState {
        case Uninitialized, Available, Error
    }

    private var state = ProgramState.Uninitialized
    open var program: GLuint = 0
    open var available: Bool {
        return (self.state == ProgramState.Available)
    }

    init?(vshSource: String, fshSource: String) {
        self.program = self.createProgram(vshSource, fshSource)
        if (!self.available) {
            return nil
        }
    }

    open func useProgram() -> Bool {
        if (self.available) {
            glUseProgram(self.program)
        }
        return self.available
    }

    private func createProgram(_ vshSource: String, _ fshSource: String) -> GLuint {
        let vertexShader = self.createShader(vshSource, GLenum(GL_VERTEX_SHADER))
        let fragmentShader = self.createShader(fshSource, GLenum(GL_FRAGMENT_SHADER))

        defer {
            glDeleteShader(fragmentShader)
            glDeleteShader(vertexShader)
        }

        let shaderProgram = glCreateProgram()
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)
        glLinkProgram(shaderProgram)

        var sucess: GLint = 0
        glGetProgramiv(shaderProgram, GLenum(GL_LINK_STATUS), &sucess)
        if (sucess == 0) {
            var log = [CChar](repeating: CChar(0), count: 512)
            glGetProgramInfoLog(shaderProgram, 512, nil, &log)
            print("program link error:\n" + String(utf8String: log)!)
            self.state = ProgramState.Error
        }
        else {
            self.state = ProgramState.Available
        }

        return shaderProgram
    }

    private func createShader(_ shaderSource: String, _ programType: GLenum) -> GLuint {
        var rawSourceRef = UnsafePointer<GLchar>? (shaderSource.cString(using: String.Encoding.ascii)!)
        let shader = glCreateShader(GLenum(programType))
        glShaderSource(shader, 1, &rawSourceRef, nil)
        glCompileShader(shader)

        var sucess: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &sucess)
        if (sucess == 0) {
            var log = [CChar](repeating: CChar(0), count: 512)
            glGetShaderInfoLog(shader, 512, nil, &log)
            print("shader compile error:\n" + String(utf8String: log)!)
            self.state = ProgramState.Error
        }

        return shader
    }

    deinit {
        if (self.available) {
            glDeleteProgram(self.program)
        }
    }
}
