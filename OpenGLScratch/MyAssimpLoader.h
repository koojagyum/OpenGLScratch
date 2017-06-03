//
//  MyAssimp.h
//  OpenGLScratch
//
//  Created by Jagyum Koo on 03/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

#ifndef MyAssimp_h
#define MyAssimp_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    MyAssimpTextureType_Count,
} MyAssimpTextureType;

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords;
    GLKVector3 tangent;
    GLKVector3 bitangent;
} MyAssimpVertex;

typedef struct {
    GLint textureId;
    MyAssimpTextureType type;
} MyAssimpTexture;

@interface MyAssimpMesh : NSObject

@property (nonatomic, readwrite) NSArray<NSValue *> *vertices;
@property (nonatomic, readwrite) NSArray<NSValue *> *indices;
@property (nonatomic, readwrite) NSArray<NSValue *> *textures;

@end

@interface MyAssimpLoader : NSObject

@property (nonatomic, readonly) NSMutableArray<MyAssimpMesh*> *meshes;

- (id)initWithPath:(NSString *)path;
- (void)loadModel:(NSString *)path;

@end


@interface NSValue (MyAssimpVertex)
    
+ (instancetype)valuewithMyAssimpVertex:(MyAssimpVertex)value;
@property (readonly) MyAssimpVertex myAssimpVertexValue;
    
@end

#endif /* MyAssimp_h */
