//
//  MultipleMarkerViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan
//

/*
 
 This class demonstrates using a .KARMarker file to store multiple marker images. Using this file format will result in a smaller project size when compared to including the images directly. The markers for this demo are included in this repository.
*/


#import "MultipleMarkerViewController.h"

@implementation MultipleMarkerViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up.
- (void)setupContent
{
    // Create an image trackable set
    // This set contains album cover markers that we can detect
    
    //The marker images are included in this repository in the "Album Markers" folder
    ARImageTrackableSet *trackableSet = [[ARImageTrackableSet alloc] initWithBundledFile:@"albumMarkers.KARMarker"];
    
    // Initialise the ARImageTrackerManager
    // This step should only be performed once
    [[ARImageTrackerManager getInstance] initialise];
    
    // Add all of the markers in the trackable set to the tracker manager
    [self addTrackablesToTrackerManager:trackableSet];
    
    // For all of the trackables in the set, add target-action pairs that get called when a marker is detected or lost
    [self addTrackingTargetsForTrackableSet:trackableSet];
}

- (void)addTrackablesToTrackerManager:(ARImageTrackableSet *)trackableSet
{
    // Get the ARImageTrackerManager singleton and initialise it
    ARImageTrackerManager *trackerManager = [ARImageTrackerManager getInstance];
    
    // Add the image trackable set to tracker manager
    [trackerManager addTrackableSet:trackableSet];
}

- (void)addTrackingTargetsForTrackableSet:(ARImageTrackableSet *)trackableSet
{
    for (ARImageTrackable *trackable in trackableSet.trackables)
    {
        // Add target-action pair for when a trackable has been detected
        [trackable addTrackingEventTarget:self action:@selector(trackableDetected:) forEvent:ARImageTrackableEventDetected];
        
        // Add target-action pair for when a trackable is lost
        [trackable addTrackingEventTarget:self action:@selector(trackableLost:) forEvent:ARImageTrackableEventLost];
    }
}

// Method called when any of the trackables are detected
- (void)trackableDetected:(ARImageTrackable *)sender
{
    // Create an image node of the Kudan Cow and add it to the trackable
    ARImageNode *cowNode = [self createImageNode:@"Kudan Cow" scale:0.5];
    [sender.world addChild:cowNode];
}

// Method called when any of the trackables are lost
- (void)trackableLost:(ARImageTrackable *)sender
{
    // Remove the cow image node from the lost trackable
    [sender.world removeAllChildren];
}

- (ARImageNode *)createImageNode:(NSString *)imageName scale:(float)scale
{
    ARImageNode *imageNode = [[ARImageNode alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageNode.scale = [ARVector3 vectorWithValues:scale];
    
    return imageNode;
}

@end
