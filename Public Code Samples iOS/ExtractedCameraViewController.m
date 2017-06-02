//
//  ExtractedCameraViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 This class is a demonstration of the extracted camera feature in the iOS SDK. The ARExtractedCameraTexture is a texture that takes its data directly from the camera stream. This can be used during rendering to deform the camera texture. In this example, we will deform the camera feed in a region defined by a marker in order to create a heartbeat effect which appears to protrude from the marker. We start with an animated model of a heartbeat and then add the extracted camera texture.
 
*/

#import "ExtractedCameraViewController.h"

@implementation ExtractedCameraViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up
- (void)setupContent
{
    // Create the image trackable and add it to the image tracker manager
    ARImageTrackable *legoTrackable = [self createLegoTrackableWithName:@"Lego Marker"];
    
    // Create the model
    ARModelNode *heartbeatModel = [self createModelNodeWithBundledFile:@"heartbeat.armodel"];
    
    // Create and set up the extracted camera texture
    ARExtractedCameraTexture *extractedTexture = [self getExtractedTextureFromTrackable:legoTrackable];
    
    // Apply the extracted texture to the model
    [self applyTexture:extractedTexture.texture toModel:heartbeatModel];
    
    // Add the model to the trackable and position appropriately
    [self addModel:heartbeatModel toTrackable:legoTrackable];
}


// This method creates and returns an ARImageTrackable and adds it to the ARImageTrackerManager singleton
- (ARImageTrackable *)createLegoTrackableWithName:(NSString *)name
{
    // Get the image that we want to use for the trackable
    UIImage *legoImage = [UIImage imageNamed:@"Lego Marker Image"];
    
    // Create the trackable with an image and a name
    ARImageTrackable *trackable =  [[ARImageTrackable alloc] initWithImage:legoImage name:name];
    
    // Initialise the tracker manager and add the newly created trackable to it
    ARImageTrackerManager *manager = [ARImageTrackerManager getInstance];
    [manager initialise];
    
    [manager addTrackable:trackable];
    
    return trackable;
}

// This method creates and returns an ARModelNode from a .armodel file
- (ARModelNode *)createModelNodeWithBundledFile:(NSString *)file
{
    // Create a model importer and get the node
    ARModelImporter *modelImporter = [[ARModelImporter alloc] initWithBundled:file];
    
    // Gets the node representing the model imported from the .armodel file
    ARModelNode *model = [modelImporter getNode];
    
    return model;
}

// This method creates and returns an ARExtractedCameraTexture with the camera data region defined by an ARImageTrackable
- (ARExtractedCameraTexture *)getExtractedTextureFromTrackable:(ARImageTrackable *)trackable
{
    // Initialise the ARExtractedCameraTexture with width and height
    // Maximum width and height is 2048. Recommended width 512 for balance between performance and quality
    
    // In this case we can choose the texture to have the same resolution as the lego marker image
    ARExtractedCameraTexture *extractedTexture = [[ARExtractedCameraTexture alloc] initWithWidth:trackable.width height:trackable.height];
    
    // The node which defines the region of the camera image the texture should be extracted from
    // We choose the lego trackable as the region to get the texture from
    
    extractedTexture.srcNode = trackable.world;
    extractedTexture.srcWidth = trackable.width;
    extractedTexture.srcHeight = trackable.height;
    
    return extractedTexture;
}

- (void)applyTexture:(ARTexture *)texture toModel:(ARModelNode *)model
{
    // Create a new material from the extracted camera texture
    ARTextureMaterial *textureMaterial = [[ARTextureMaterial alloc] initWithTexture:texture];
    
    // Apply the texture to every mesh in the model
    for (ARMeshNode *meshNode in model.meshNodes)
    {
        // Set the mesh's material to the newly created material
        meshNode.material = textureMaterial;
    }
}

- (void)addModel:(ARModelNode *)model toTrackable:(ARImageTrackable *)trackable
{
    // Add the model to the trackable's world
    [trackable.world addChild:model];
    
    // The trackable world's Y axis corresponds to the normal to the marker's surface
    // Therefore we must rotate the model if we want this model to lie flush with the marker
    model.orientation = [ARQuaternion quaternionWithDegrees:90 axisX:1 y:0 z:0];
    
    // The model has width and height 150, so we need to scale with these values in mind in order for the model to cover the entire marker
    // The y component of scale relates to the scale of the protrusion of the heartbeat animation
    model.scale = [ARVector3 vectorWithValuesX:trackable.width / 150.0 y:10 z:trackable.height / 150.0];
    
    // Set the model animation to loop
    model.shouldLoop = YES;
    
    // Start the model animation
    [model start];
}

@end
