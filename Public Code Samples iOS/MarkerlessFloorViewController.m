//
//  MarkerlessFloorViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 In this demo we demonstrate one particular implementation of markerless tracking, which we refer to as "Floor Tracking".
 The floor aspect refers to the fact that we add the target node as a child of the gyroplacemanager's world.
 
 This world is placed on a plane representing the floor and so can be used for tracking AR content that remains fixed relative to a point on the floor
 
 */

#import "MarkerlessFloorViewController.h"

@implementation MarkerlessFloorViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up
- (void)setupContent
{
    // Choose the orientation of our target and tracking nodes
    // We start with a rotation 180 about the y axis so that the text on the image is facing us
    // Then we add a rotation of -90 degrees about the x axis so that the node lies flat on the floor
    
    ARQuaternion *floorOrientation = [ARQuaternion quaternionWithDegrees:180 axisX:0 y:1 z:0];
    [floorOrientation localMultiplyByQuaternion:[ARQuaternion quaternionWithDegrees:-90 axisX:1 y:0 z:0]];
    
    // Create a target node. A target node is a node whose position is used to determine the initial position of arbitrack's world when arbitrack is started
    // The target node in this case is an image node of the Kudan Cow
    ARImageNode *floorTargetNode = [self createImageNodeWithImageNamed:@"Cow Target" orientation:floorOrientation scale:0.3];
    
    // Add our target node to the gyroplacemanager's world
    [self addNodeToGyroPlaceManager:floorTargetNode];
    
    // Create an image node to place in arbitrack's world. We can choose the tracking node to have the same orientation as the target node
    ARImageNode *trackingImageNode = [self createImageNodeWithImageNamed:@"Cow Tracking" orientation:floorOrientation scale:1.0];
    
    // Set up arbiTrack
    [self setUpArbiTrackWithTargetNode:floorTargetNode childNode:trackingImageNode];
}

- (ARImageNode *)createImageNodeWithImageNamed:(NSString *)imageName orientation:(ARQuaternion *)orientation scale:(float)scale
{
    ARImageNode *imageNode = [[ARImageNode alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageNode.orientation = orientation;
    imageNode.scale = [ARVector3 vectorWithValues:scale];
    
    return imageNode;
}

- (void)addNodeToGyroPlaceManager:(ARNode *)node
{
    // The gyroplacemanager positions it's world on a plane that represents the floor.
    // You can adjust the floor depth (The distance between the device and the floor) using ARGyroPlaceManager's floor depth property.
    // The default floor depth is -150
    ARGyroPlaceManager *gyroPlaceManager =  [ARGyroPlaceManager getInstance];
    [gyroPlaceManager initialise];
    
    // Add the node to the gyroplacemanager world
    [gyroPlaceManager.world addChild:node];
}

- (void)setUpArbiTrackWithTargetNode:(ARNode *)targetNode childNode:(ARNode *)childNode
{
    // Get the arbitrack manager and initialise it
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    [arbiManager initialise];
    
    // Set it's target node
    arbiManager.targetNode = targetNode;
    
    // Add the tracking image node to the arbitrack world
    [arbiManager.world addChild:childNode];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    
    // If arbitrack is tracking, stop the tracking so that it's world is no longer rendered, and make it's target nodes visible
    if (arbiManager.isTracking)
    {
        [arbiManager stop];
        arbiManager.targetNode.visible = YES;
    }
    
    // If it's not tracking, start the tracking and hide the target node
    
    // When arbitrack has started, it will take the initial position of it's target node and it's world will be rendered to the screen. After this, it's pose will be continually updated to give the appearance of it remaining in the same place
    else
    {
        [arbiManager start];
        arbiManager.targetNode.visible = NO;
    }
}

@end
