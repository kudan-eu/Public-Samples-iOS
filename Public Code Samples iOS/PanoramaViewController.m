
//
//  PanoramaViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 This class is a demonstration of the panorama feature in the iOS SDK. Using the gyroscope, you can explore a 360 degree image.
 
*/

#import "PanoramaViewController.h"

@interface PanoramaViewController () <ARRendererDelegate>

@property ARPanoNode *panoNode;

// Gesture recogniser we will use to rotate the panorama with a pan gesture
@property UIPanGestureRecognizer *panRecogniser;

@end

@implementation PanoramaViewController

// Set up UI features
- (void)viewDidLoad
{
    // Set up the gesture recogniser to detect a pan gesture on the screen
    [self setUpGestureRecogniser];
}


// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up

- (void)setupContent
{
    // Start with an array of strings of the names of the images that will make up our pano cube
    // To work correctly the order of images must be: front, back, left, right, up, down
    NSArray *imageArray = @[@"HozomonGate_f",@"HozomonGate_b",@"HozomonGate_l",@"HozomonGate_r",@"HozomonGate_u",@"HozomonGate_d"];
    
    // Create the pano node with our images
    self.panoNode = [[ARPanoNode alloc] initWithImages:imageArray];
    
    // Initialise the gyromanager
    ARGyroManager *gyroManager = [ARGyroManager getInstance];
    [gyroManager initialise];
    
    // Start the ARGyroManager
    [gyroManager start];
    
    // Add the pano node as a child of the gyromanager's world
    [gyroManager.world addChild:self.panoNode];
}

// Method called when the gesture recogniser reconises a gesture
- (void)panRecognised:(UIPanGestureRecognizer *)recogniser
{
    // Get the velocity of the gesture, that is, the amount it's translation has changed since it was last recorded
    CGPoint velocity = [self.panRecogniser velocityInView:self.view];
    
    // Adjust how much the pano is rotated for a given velocity
    float rotationScale = 0.002;
    
    // Rotate our pano node
    [self.panoNode rotateByDegrees:-velocity.x*rotationScale axisX:0 y:1 z:0];
}

// The gesture recogniser will allow us to test whether a pan gesture has occurred
- (void)setUpGestureRecogniser
{
    // Create our gesture recogniser and add it to the view
    self.panRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognised:)];
    [self.view addGestureRecognizer:self.panRecogniser];
}

@end
