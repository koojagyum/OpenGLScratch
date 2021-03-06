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

    init?(vshSource: String, fshSource: String, gshSource: String?) {
        self.program = self.createProgram(vshSource, fshSource, gshSource)
        if (!self.available) {
            return nil
        }
    }

    convenience init?(vshSource: String, fshSource: String) {
        self.init(vshSource: vshSource, fshSource: fshSource, gshSource: nil)
    }

    open func useProgram() -> Bool {
        if (self.available) {
            glUseProgram(self.program)
        }
        return self.available
    }

    open func useProgramWith(block: (MyOpenGLProgram) -> ()) {
        if self.useProgram() {
            block(self)
        }
    }

    private func createProgram(_ vshSource: String, _ fshSource: String) -> GLuint {
        return self.createProgram(vshSource, fshSource, nil)
    }

    private func createProgram(_ vshSource: String, _ fshSource: String, _ gshSource: String?) -> GLuint {
        let vertexShader = self.createShader(vshSource, GLenum(GL_VERTEX_SHADER))
        let fragmentShader = self.createShader(fshSource, GLenum(GL_FRAGMENT_SHADER))
        let geometryShader = self.createShader(gshSource, GLenum(GL_GEOMETRY_SHADER))

        defer {
            glDeleteShader(fragmentShader)
            glDeleteShader(vertexShader)
            if geometryShader != 0 {
                glDeleteShader(geometryShader)
            }
        }

        let shaderProgram = glCreateProgram()
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)
        if geometryShader != 0 {
            glAttachShader(shaderProgram, geometryShader)
        }
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

    private func createShader(_ shaderSource: String?, _ programType: GLenum) -> GLuint {
        guard let shaderSourceUnwrapped = shaderSource else {
            return 0
        }

        var rawSourceRef = UnsafePointer<GLchar>? (shaderSourceUnwrapped.cString(using: String.Encoding.ascii)!)
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

    func setInt(name: String, value: GLint) {
        glUniform1i(glGetUniformLocation(self.program, name), value)
    }

    func setFloat(name: String, value: GLfloat) {
        glUniform1f(glGetUniformLocation(self.program, name), value)
    }

    func setMat4(name: String, value: GLKMatrix4) {
        let location = glGetUniformLocation(self.program, name)
        var v = value
        MyOpenGLUtils.uniformMatrix4fv(location, 1, GLboolean(GL_FALSE), &v)
    }

    func setMat3(name: String, value: GLKMatrix3) {
        let location = glGetUniformLocation(self.program, name)
        var v = value
        MyOpenGLUtils.uniformMatrix3fv(location, 1, GLboolean(GL_FALSE), &v)
    }

    func setVec3(name: String, value: GLKVector3) {
        let location = glGetUniformLocation(self.program, name)
        var v = value
        MyOpenGLUtils.uniform3fv(location, 1, &v)
    }

    deinit {
        if (self.available) {
            glDeleteProgram(self.program)
        }
    }
}
