//
//  MarkerViewController.m
//  Sample Code - ObjC
//
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 This class is a demonstration of a simple marker tracking set up. We create a marker, add it to our ARImageTrackerManager, and then add an image node of the Kudan logo to the trackable. We also create a UILabel and update it to reflect the change in tracking status.
*/

#import "MarkerViewController.h"

@interface MarkerViewController ()

// Label that we will change the text of to reflect the change in tracking status
@property IBOutlet UILabel *trackingStatusLabel;

@end

@implementation MarkerViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up

- (void)setupContent
{
    // Create the image trackable and add it to the image tracker manager
    ARImageTrackable *legoTrackable = [self createTrackableWithImageNamed:@"Lego Marker Image" andName:@"Lego Marker"];
    
    // Create image node to add to trackable
    ARImageNode *cowNode = [[ARImageNode alloc] initWithImage:[UIImage imageNamed:@"Kudan Cow"]];
    
    // Add target-action pairs for various tracking events
    [self addTrackingTargetsForTrackable:legoTrackable];
    
    // Add the cow node to the trackable's world
    [legoTrackable.world addChild:cowNode];
}

- (ARImageTrackable *)createTrackableWithImageNamed:(NSString *)imageName andName:(NSString *)markerName
{
    // Get the image that we want to use for our trackable
    UIImage *markerImage = [UIImage imageNamed:imageName];
    
    // Create our trackable with an image and a name
    ARImageTrackable *trackable =  [[ARImageTrackable alloc] initWithImage:markerImage name:markerName];
    
    // Get the tracker manager and add our newly created trackable to it
    ARImageTrackerManager *manager = [ARImageTrackerManager getInstance];
    [manager initialise];

    [manager addTrackable:trackable];
    
    return trackable;
}

- (void)addTrackingTargetsForTrackable:(ARImageTrackable *)trackable
{
    // Add target-action pair for when this trackable is lost
    [trackable addTrackingEventTarget:self action:@selector(imageLost:) forEvent:ARImageTrackableEventLost];
    
    // Add target-action pair for when the trackable is being tracked
    [trackable addTrackingEventTarget:self action:@selector(imageDetected:) forEvent:ARImageTrackableEventDetected];
}

// Method called when the trackable has been Lost
- (void)imageLost:(ARImageTrackable *)sender
{
    // As tracking is performed on a background thread, we need to dispatch any UI updates to the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trackingStatusLabel.text = @"Searching for markers...";
        self.trackingStatusLabel.textColor = [UIColor whiteColor];
    });
}
// Method called when the trackable has been detected
- (void)imageDetected:(ARImageTrackable *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trackingStatusLabel.text = @"Marker Tracking";
        self.trackingStatusLabel.textColor = [UIColor greenColor];
    });
}

@end
