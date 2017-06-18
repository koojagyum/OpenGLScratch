//
//  MyOpenGLTextureCache.swift
//  OpenGLScratch
//
//  Created by Jagyum Koo on 18/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

import Foundation
import GLKit

class MyOpenGLTextureCache {
    static let textureMap = NSMapTable<NSString, MyOpenGLTexture>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.weakMemory)

    static func textureAt(path: String) -> MyOpenGLTexture? {
        if let cachedTexture = textureMap.object(forKey: path as NSString) {
            return cachedTexture
        }
        let newTexture = MyOpenGLTexture(path: path)
        textureMap.setObject(newTexture, forKey: path as NSString)
        return newTexture
    }
}
