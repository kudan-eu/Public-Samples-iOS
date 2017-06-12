//
//  SimultaneousTrackingViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 This class is a demonstration of the simultaneous tracking feature of the iOS SDK. The framework has no hard limit on the number of markers that can be simultaneously detected and tracked. However, we have the option to limit the number of simultaneous detections which can improve performance and battery life.
 
 In this demo we split our standard lego marker into four pieces and add images of numbers as children of the pieces. We then add a stepper so that we can experiment with adjusting the maximum simultaneous tracking property.
 
 */

#import "SimultaneousTrackingViewController.h"

@interface SimultaneousTrackingViewController ()

@property IBOutlet UILabel *maxTrackingLabel;

@end

@implementation SimultaneousTrackingViewController

- (void)setupContent
{
    // An array that contains the names of the images of the pieces of our lego marker
    NSArray <NSString *> *trackableImageNames = @[@"legoOne", @"legoTwo", @"legoThree", @"legoFour"];
    
    // An array that contains the names of the images of pictures of numbers
    NSArray <NSString *> *imageNodeNames = @[@"oneImage", @"twoImage", @"threeImage", @"fourImage"];
    
    // Create an array of trackables from an array of image names
    NSArray <ARImageTrackable *> *trackables = [self createTrackablesFromImagesNamed:trackableImageNames];
    
    // Create an array of image nodes from an array of image names
    NSArray <ARImageNode *> *imageNodes = [self createImageNodesFromImagesNamed:imageNodeNames];
    
    // Add the image nodes to the corresponding trackable
    [self addImageNodes:imageNodes toTrackables:trackables];
    
     // Initialise the image tracker manager. This step should be performed exactly once
    [[ARImageTrackerManager getInstance] initialise];
    
    // Add the trackables to the image tracker manager
    [self addTrackablesToManager:trackables];
}

- (NSArray *)createTrackablesFromImagesNamed:(NSArray *)imageNames
{
    // Create an array of image trackables
    NSMutableArray *trackables = [[NSMutableArray alloc] init];
    
    for (NSString *imageName in imageNames)
    {
        // Create a UIImage instance from an image name
        UIImage *trackableImage = [UIImage imageNamed:imageName];
        
        // Create an ARImageTrackable from that image
        ARImageTrackable *trackable = [[ARImageTrackable alloc] initWithImage:trackableImage name:imageName];
        
        // Add the newly created trackable to our array
        [trackables addObject:trackable];
    }
    
    // Return an immutable array containing our trackables
    return [NSArray arrayWithArray:trackables];
}

- (NSArray *)createImageNodesFromImagesNamed:(NSArray *)imageNames
{
    NSMutableArray *imageNodes = [[NSMutableArray alloc] init];
    
    for (NSString *imageName in imageNames)
    {
        // Create a UIImage corresponding to the image name
        UIImage * nodeImage = [UIImage imageNamed:imageName];
        
        // Create an image node from that image
        ARImageNode *imageNode = [[ARImageNode alloc] initWithImage:nodeImage];
        
        // Add that image node to our array
        [imageNodes addObject:imageNode];
        
    }
    
    // Return an immutable array containing our image nodes
    return [NSArray arrayWithArray:imageNodes];
}

- (void)addImageNodes:(NSArray *)imageNodes toTrackables:(NSArray *)trackables
{
    // This method only works if there are the same number of image nodes as there are trackables to add those image nodes to
    if (imageNodes.count == trackables.count)
    {
        // For each trackable, add the corresponding image node
        for (int i = 0; i < imageNodes.count; i++)
        {
            ARImageTrackable *trackable = trackables[i];
            ARImageNode *imageNode = imageNodes[i];
            [trackable.world addChild:imageNode];
        }
    }
    else
    {
        NSLog(@"Error: Arrays have different sizes");
    }
}

- (void)addTrackablesToManager:(NSArray *)trackables
{
    ARImageTrackerManager *manager = [ARImageTrackerManager getInstance];
    
    // Add the trackables in the array to the trackable manager
    for (ARImageTrackable *trackable in trackables)
    {
        [manager addTrackable:trackable];
    }
}

// Change the maximum simultaneous tracking in response to a UI event
- (IBAction)stepperChanged:(UIStepper *)sender
{
    // Adjust our label text to reflect the new maximum simultaneous tracking number
    self.maxTrackingLabel.text = [NSString stringWithFormat:@"%i",(int)sender.value];
    
    if ((int)sender.value == 0)
    {
        self.maxTrackingLabel.text = [self.maxTrackingLabel.text stringByAppendingString:@" (Unlimited) "];
    }
    
    // Adjusts the maximum number of trackables that can be simultaneously tracked
    
    // Note: If a number of trackables are currently being tracked, setting the maximum to a value below this number will not cause any trackables to be lost.
    
    // Instead it means that any new trackables will not be detected if the number that is currently being tracked is
    // equal to or above the maximum value
    
    [[ARImageTrackerManager getInstance] setMaximumSimultaneousTracking:(int)sender.value];
}

@end
