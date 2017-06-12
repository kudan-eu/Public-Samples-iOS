//
//  MarkerlessWallViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

#import "MarkerlessWallViewController.h"

/*
 
 In this demo we demonstrate one particular implementation of markerless tracking, which we refer to as "Wall Tracking". 
 
 For this implementation, we add the target node as a child of the camera node associated with the content view port.
 This causes the target node to stay in a fixed position relative to the screen, regardless of the device orientation
 
 */

@interface MarkerlessWallViewController () <ARArbiTrackerManagerDelegate>

// Keep a reference to the wall target node to allow for rotations when the device rotates
@property ARNode *wallTargetNode;

@end

@implementation MarkerlessWallViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up
- (void)setupContent
{
    // We choose the orientation of our wall node so that the target node is orientated towards the user for a particular device orientation
    ARQuaternion *wallOrientation = [self wallOrientationForDeviceOrientation:[UIDevice currentDevice].orientation];
    
    // Create a target node. A target node is a node whose position is used to determine the initial position of arbitrack's world when arbitrack is started
    // The target node in this case is an image of the Kudan Cow
    
    // Place the target node a distance of 1000 units behind the screen
    ARVector3 *wallPosition = [ARVector3 vectorWithValuesX:0 y:0 z:-1000];
    self.wallTargetNode = [self createImageNodeWithImageNamed:@"Cow Target" orientation:wallOrientation scale:0.5 position:wallPosition];

    // Add our target node as a child of the camera node associated with the content view port
    // Place the target node a distance of 1000 behind the screen
    [self.cameraView.contentViewPort.camera addChild:self.wallTargetNode];
    
    // Create an image node to place in arbitrack's world
    ARImageNode *trackingImageNode = [self createImageNodeWithImageNamed:@"Cow Tracking" orientation:[ARQuaternion quaternionWithIdentity] scale:1.0 position:[ARVector3 vectorWithZero]];
    
    // Set up arbitrack
    [self setUpArbiTrackWithTargetNode:self.wallTargetNode andChildNode:trackingImageNode];
}

- (ARImageNode *)createImageNodeWithImageNamed:(NSString *)imageName orientation:(ARQuaternion *)orientation scale:(float)scale position:(ARVector3 *)position
{
    ARImageNode *imageNode = [[ARImageNode alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageNode.orientation = orientation;
    imageNode.scale = [ARVector3 vectorWithValues:scale];
    imageNode.position = position;
    
    return imageNode;
}

- (void)setUpArbiTrackWithTargetNode:(ARNode *)targetNode andChildNode:(ARNode *)childNode
{
    // Get the arbitrack manager and initialise it
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    [arbiManager initialise];
    
    // Set it's target node
    arbiManager.targetNode = targetNode;
    
    // Add the tracking image node to the arbitrack world
    [arbiManager.world addChild:childNode];
    
    // Add this view controller as a delegate of arbitrack
    [arbiManager addDelegate:self];
}

// Delegate method called when abritrack's world starts tracking and recieving gyro updates
- (void)arbiTrackStarted
{
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    
    // Rotate the tracking node so that it has the same full orientation as the target node
    // As the target node is a child of the camera world and the tracking node is a child of arbitrack's world, we must first rotate the tracking node by the inverse of arbitrack's world orientation.
    // This is so to the eye it has the same orientation as the target node
    
    // At this point we can update the orientation of the tracking node as arbitrack will have updated it's orientation
    ARQuaternion *targetFullOrientation = arbiManager.targetNode.fullOrientation;
    ARNode *trackingNode = arbiManager.world.children.firstObject;
    trackingNode.orientation = [arbiManager.world.orientation.inverse multiplyByQuaternion:targetFullOrientation];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    
    // If arbitrack is tracking, stop tracking so that it's world is no longer rendered, and set it's target node to visible
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

// Called when the device changes interface orientations
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Update the wall target node orientation
    self.wallTargetNode.orientation = [self wallOrientationForDeviceOrientation:[UIDevice currentDevice].orientation];
}

// Returns the correct orientation for the wall target node for various device orientations
- (ARQuaternion *)wallOrientationForDeviceOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            return [ARQuaternion quaternionWithDegrees:-90 axisX:0 y:0 z:1];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return [ARQuaternion quaternionWithDegrees:90 axisX:0 y:0 z:1];
            break;
        case UIDeviceOrientationLandscapeLeft:
            return [ARQuaternion quaternionWithDegrees:-180 axisX:0 y:0 z:1];
            break;
        case UIDeviceOrientationLandscapeRight:
            return [ARQuaternion quaternionWithIdentity];
            break;
        default:
            return [ARQuaternion quaternionWithDegrees:-90 axisX:0 y:0 z:1];
            break;
    }
}

@end
