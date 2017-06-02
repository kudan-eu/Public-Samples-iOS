//
//  MarkerToMarkerlessViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 This class demonstrates how marker and markerless tracking can be combined. To ensure a seamless transition from maker to markerless tracking we ensure that a node's full orientation is preserved as it is reparented from the trackable's world, to arbitrack's world.
 
*/


#import "MarkerToMarkerlessViewController.h"

// ARArbiTrackerManagerDelegate is a protocol that allows us to receive a method call when Arbitrack is started
@interface MarkerToMarkerlessViewController () <ARArbiTrackerManagerDelegate>

// Button that controls the tracking mode
@property IBOutlet UIButton *switchToArbiButton;

@end

@implementation MarkerToMarkerlessViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up
- (void)setupContent
{
    // Create an image node of the Kudan Cow
    ARImageNode *cowNode = [self createImageNodeWithImageNamed:@"Kudan Cow" nodeName:@"Cow" scale:2.0];
    
    // Initialise the image tracker manager. This step should only be performed once
    [[ARImageTrackerManager getInstance] initialise];
    // Create the image trackable and add it to the tracker manager
    ARImageTrackable *legoTrackable = [self createTrackableWithImageNamed:@"Lego Marker Image" andName:@"Lego Marker"];
    
    // Add the cow node as a child of the trackable's world
    [legoTrackable.world addChild:cowNode];
    
    // Set up arbitrack and set it's target node to the image trackable's world
    // This means when arbitrack is started it will initially position it's world at the same position as the trackable's world
    [self setUpArbiTrackWithTargetNode:legoTrackable.world];
}

- (ARImageNode *)createImageNodeWithImageNamed:(NSString *)imageName nodeName:(NSString *)nodeName scale:(float)scale
{
    ARImageNode *imageNode = [[ARImageNode alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageNode.name = nodeName;
    imageNode.scale = [ARVector3 vectorWithValues:scale];
    
    return imageNode;
}

- (ARImageTrackable *)createTrackableWithImageNamed:(NSString *)imageName andName:(NSString *)markerName
{
    // Create the image that we want to use for our trackable
    UIImage *markerImage = [UIImage imageNamed:imageName];
    
    // Create our trackable with an image and a name
    ARImageTrackable *trackable =  [[ARImageTrackable alloc] initWithImage:markerImage name:markerName];
    
    // Get the tracker manager and add our newly created trackable to it
    [[ARImageTrackerManager getInstance] addTrackable:trackable];
    
    return trackable;
}

- (void)setUpArbiTrackWithTargetNode:(ARNode *)targetNode
{
    // Get the arbitrack manager and initialise it
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    [arbiManager initialise];
     
    arbiManager.targetNode = targetNode;
    
    // Add this view controller as a delegate of the arbi manager so that it gets sent a method call when the arbitrack has positioned it's world
    [arbiManager addDelegate:self];
}

// Method that is called when we press the button that toggles the tracking mode
- (IBAction)toggleArbiTrack:(UIButton *)sender
{
    // Find the lego trackable from it's name
    ARImageTrackable *legoTrackable = [[ARImageTrackerManager getInstance] findTrackableByName:@"Lego Marker"];
    
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    
    // If we are not arbitracking, start arbitrack
    // We don't add the image node to abrbitrack at this point as it's world's transformation has not updated yet
    // Once the arbiTrackStarted method has been called, arbitrack's world transformation will be correct and we can add the AR content to it
    if (!arbiManager.isTracking)
    {
        // If the marker is not currently detected, exit the method and don't switch to arbitrack
        if (!legoTrackable.isDetected)
        {
            return;
        }
        
        [arbiManager start];
    }
    
    // If we are tracking
    else
    {
        // Find the cow node from it's name in arbitrack's world
        ARImageNode *cowNode = (ARImageNode *)[arbiManager.world findChildWithName:@"Cow"];
        
        // Stop updating the arbitrack world's position and remove the cow node as a child
        [arbiManager stop];
        
        // Adjust the node's orientation to lie flat on the marker
        cowNode.orientation = [ARQuaternion quaternionWithIdentity];
        
        [arbiManager.world removeChild:cowNode];
        
        // Add the cow node as a child once more of the image trackable's world
        [legoTrackable.world addChild:cowNode];
        
        // Update the button's title to reflect the tracking mode
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.switchToArbiButton setTitle:@"Switch to Arbitrack" forState:UIControlStateNormal];
        });
    }
}

// Delegate method called once arbitrack has started
- (void)arbiTrackStarted
{
    // Find the lego trackable from it's name
    ARImageTrackable *legoTrackable = [[ARImageTrackerManager getInstance] findTrackableByName:@"Lego Marker"];
    
    // Find the cow node from it's name in the lego trackable's world
    ARImageNode *cowNode = (ARImageNode *)[legoTrackable.world findChildWithName:@"Cow"];
    
    ARArbiTrackerManager *arbiManager = [ARArbiTrackerManager getInstance];
    
    // Alter the orientation of the cow node to preserve it's full orientation as it's reparented
    cowNode.orientation = [arbiManager.world.orientation.inverse multiplyByQuaternion:cowNode.fullOrientation];
    
    // Remove the cow node as a child of the trackable world and add it to the arbitrack world
    [legoTrackable.world removeChild:cowNode];
    [arbiManager.world addChild:cowNode];
    
    // Update the button's title to reflect the tracking mode
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.switchToArbiButton setTitle:@"Switch to Marker" forState:UIControlStateNormal];
    });
}

@end
