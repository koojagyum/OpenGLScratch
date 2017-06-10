//
//  MyAssimpScene.m
//  OpenGLScratch
//
//  Created by Jagyum Koo on 02/06/2017.
//  Copyright © 2017 Jagyum Koo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import <assimp/Importer.hpp>
#import <assimp/scene.h>
#import <assimp/postprocess.h>

#import "MyAssimpLoader.h"

@implementation NSValue (MyAssimpVertex)

+ (instancetype)valuewithMyAssimpVertex:(MyAssimpVertex)value
{
    return [self valueWithBytes:&value objCType:@encode(MyAssimpVertex)];
}

- (MyAssimpVertex) myAssimpVertexValue
{
    MyAssimpVertex value;
    [self getValue:&value];
    return value;
}

@end

@implementation MyAssimpMesh
@end

@implementation MyAssimpTextureInfo
@end

@implementation MyAssimpLoader

- (id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    _meshes = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithPath:(NSString *)path
{
    if (!(self = [self init])) {
        return nil;
    }
    [self loadModel:path];
    return self;
}

- (void)loadModel:(NSString *)path
{
    Assimp::Importer importer;
    const aiScene *scene = importer.ReadFile([path cStringUsingEncoding:NSASCIIStringEncoding], aiProcess_Triangulate | aiProcess_FlipUVs | aiProcess_CalcTangentSpace);
    if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
        NSLog(@"ERRER::ASSIMP:: %s", importer.GetErrorString());
        return;
    }

    // process ASSIMP's root node recursively
    [self processNode:scene->mRootNode withScene:scene];
}

// Processes a node in a recursive fashion.
// Processes each individual mesh located at the node and repeats this process on its children nodes(if any).
- (void)processNode:(aiNode *)node withScene:(const aiScene *)scene
{
    // process each mesh located at the current node
    for (unsigned int i = 0; i < node->mNumMeshes; i++) {
        // the node object only contains indices to index actual objects in the scene.
        // the scene contains all the data, node is just to keep stuff organized (like relations between nodes).
        aiMesh *mesh = scene->mMeshes[node->mMeshes[i]];
        [self.meshes addObject:[self processMesh:mesh withScene:scene]];
    }
    // after we've processed all of the meshes (if any)
    // we then recursively process each of the children nodes.
    for (unsigned int i = 0; i < node->mNumChildren; i++) {
        [self processNode:node->mChildren[i] withScene:scene];
    }
}

- (MyAssimpMesh *)processMesh:(aiMesh *)mesh withScene:(const aiScene *)scene
{
    MyAssimpMesh *myMesh = [[MyAssimpMesh alloc] init];
    NSMutableArray *vertices = [[NSMutableArray alloc] init];
    NSMutableArray *indices = [[NSMutableArray alloc] init];
    NSMutableArray<MyAssimpTextureInfo *> *textures = [[NSMutableArray alloc] init];

    // Walk through each of the meshs vertices
    for (unsigned int i = 0; i < mesh->mNumVertices; i++) {
        MyAssimpVertex vertex;

        // positions
        vertex.position = GLKVector3Make(mesh->mVertices[i].x, mesh->mVertices[i].y, mesh->mVertices[i].z);
        // normals
        vertex.normal = GLKVector3Make(mesh->mNormals[i].x, mesh->mNormals[i].y, mesh->mNormals[i].z);
        // texture coordinates
        if (mesh->mTextureCoords[0]) { // does the mesh contain texture coordinates?
            // A vertex can contain up to 8 different texture coordinates.
            // We thus make the assumption that we won't use models where
            // a vertex can have multiple texture coordinates
            // so we always take the first set (0).
            vertex.texCoords = GLKVector2Make(mesh->mTextureCoords[0][i].x, mesh->mTextureCoords[0][i].y);
        }
        else {
            vertex.texCoords = GLKVector2Make(0.0, 0.0);
        }
        // tangent
        vertex.tangent = GLKVector3Make(mesh->mTangents[i].x, mesh->mTangents[i].y, mesh->mTangents[i].z);
        // bitangent
        vertex.bitangent = GLKVector3Make(mesh->mBitangents[i].x, mesh->mBitangents[i].y, mesh->mBitangents[i].z);

        [vertices addObject:[NSValue valuewithMyAssimpVertex:vertex]];
    }

    // Now walk through each of the mesh's faces(a face is a mesh its triangle)
    // and retrieve the corresponding indices.
    for (unsigned int i = 0; i < mesh->mNumFaces; i++) {
        aiFace face = mesh->mFaces[i];
        // retrieve all indices of the face and store them in the indices vector
        for (unsigned int j = 0; j < face.mNumIndices; j++) {
            [indices addObject:[NSNumber numberWithInt:face.mIndices[j]]];
        }
    }

    // Process materials
    if (mesh->mMaterialIndex >= 0) {
        aiMaterial *material = scene->mMaterials[mesh->mMaterialIndex];
        // We assume a convention for a sampler names in the shaders.
        // Each diffuse texture should be named as 'texture_diffuseN' where
        // N is a sequential number ranging from 1 to MAX_SAMPLER_NUMBER.
        // Same applies to other texture as the following list summerizes:
        // diffuse: texture_diffuseN
        // specular: texture_specularN
        // normal: texture_normalN

        // 1. diffuse maps
        NSArray *diffuseTextures = [self loadMaterialTextures:material withTextureType:aiTextureType_DIFFUSE asMyAssimpTextureType:MyAssimpTextureType_Diffuse];
        [textures addObjectsFromArray:diffuseTextures];
        // 2. specular maps
        NSArray *specularTextures = [self loadMaterialTextures:material withTextureType:aiTextureType_SPECULAR asMyAssimpTextureType:MyAssimpTextureType_Specular];
        [textures addObjectsFromArray:specularTextures];
        
    }
    myMesh.vertices = vertices;
    myMesh.indices = indices;
    myMesh.textures = textures;

    return myMesh;
}

- (NSArray *)loadMaterialTextures:(aiMaterial *)mat withTextureType:(aiTextureType)withType asMyAssimpTextureType:(MyAssimpTextureType)asType
{
    NSMutableArray *textures = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < mat->GetTextureCount(withType); i++) {
        aiString str;
        mat->GetTexture(withType, i, &str);
        MyAssimpTextureInfo *texture = [[MyAssimpTextureInfo alloc] init];
        texture.filename = [NSString stringWithCString:str.C_Str() encoding:NSASCIIStringEncoding];
        texture.type = asType;
        [textures addObject:texture];
    }
    return textures;
}

    
@end
