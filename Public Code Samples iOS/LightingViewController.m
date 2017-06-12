//
//  LightingViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

/*
 
 This demo demonstrates many of the dynamic lighting features of the iOS SDK.
 We can place a number of different types lights in our scene and adjust how our model is affected by light
 
 */

#import "LightingViewController.h"

@interface LightingViewController () <ARRendererDelegate>

// We keep a reference to the sphere's material so we can adjust it's properties
@property ARLightMaterial *lightMaterial;

// This node will be positioned at the centre of the sphere and the lights will be children of this node
// Then, as we rotate this node, the light nodes will rotate around the sphere
@property ARNode *centreNode;

@property IBOutletCollection(UISegmentedControl) NSArray *materialLightingSelectors;

// We will create three different types of light, although only one will be visible at any one time
@property ARDirectionalLight *directionalLight;
@property ARPointLight *pointLight;
@property ARSpotLight *spotLight;

// Subviews
@property IBOutlet UIView *lightingView;
@property IBOutlet UIView *materialView;

@property IBOutlet UIView *positionView;
@property IBOutlet UIView *attenuationView;
@property IBOutlet UIView *innerView;
@property IBOutlet UIView *outerView;

@property IBOutlet UISlider *orientationSlider;
@property IBOutlet UISlider *positionSlider;
@property IBOutlet UISlider *attenuationSlider;
@property IBOutlet UISlider *innerSlider;
@property IBOutlet UISlider *outerSlider;

@end

// A global variable indicating if we should rotate the light around the sphere, default value is YES
BOOL _shouldRotate = YES;

@implementation LightingViewController

// This method should be overridden and all of the AR content setup placed within it
// This method is called only at the point at which the AR Content is ready to be set up.

-(void)setupContent
{
    // Place the sphere node 1000 units directly in front of the screen
    ARVector3 *spherePosition = [ARVector3 vectorWithValuesX:0 y:0 z:-1000];
    
    // Create our sphere node, place it in the middle of the scene and scale the sphere
    ARModelNode *sphereNode = [self createModelNodeWithFileName:@"sphere.armodel" scale:150.0 position:spherePosition];
    
    // Add our model node as a child of the camera node associated with the content view port
    [self.cameraView.contentViewPort.camera addChild:sphereNode];
    
    // Create our environment texture cube to add to our light material
    ARTextureCube *environment = [[ARTextureCube alloc] initWithBundledFiles:@[@"HakataRamen_r.small.jpg",@"HakataRamen_l.small.jpg",
                                                                               @"HakataRamen_u.small.jpg",@"HakataRamen_d.small.jpg",
                                                                               
                                                                               @"HakataRamen_f.small.jpg",@"HakataRamen_b.small.jpg"]];
    
    // Create the colour and normal texture
    ARTexture *colourTexture = [[ARTexture alloc] initWithUIImage:[UIImage imageNamed:@"178"]];
    ARTexture *normalTexture = [[ARTexture alloc] initWithUIImage:[UIImage imageNamed:@"178_norm"]];
    
    // Get the sphere's material, so that we can adjust it's properties
    self.lightMaterial = [self setUpLightMaterialForModel:sphereNode perPixel:YES ambient:0.5 specular:0.5
                                                shininess:128 reflectivity:0 environment:environment colourTexture:colourTexture normalTexture:normalTexture];
    
    // Create our lights and choose white as the light colour
    // Place each light 250 units behind the centre node
    ARVector3 *lightPosition = [ARVector3 vectorWithValuesX:0 y:0 z:250];
    ARVector3 *whiteColourVector = [ARVector3 vectorWithValues:1.0];
    self.directionalLight = [self setUpDirectionalLightWithColour:whiteColourVector position:[ARVector3 vectorWithVector:lightPosition]];
    self.pointLight = [self setUpPointLightWithColour:whiteColourVector position:[ARVector3 vectorWithVector:lightPosition]];
    self.spotLight = [self setUpSpotLightWithColour:whiteColourVector innerAngle:0.5 outerAngle:0.5 position:[ARVector3 vectorWithVector:lightPosition]];
    
    // Add corresponding images to lights to keep track of their position
    [self.directionalLight addChild:[self createImageNodeWithImageNamed:@"directionalLightSquare" scale:0.5]];
    [self.pointLight addChild:[self createImageNodeWithImageNamed:@"pointLightSquare" scale:0.5]];
    [self.spotLight addChild:[self createImageNodeWithImageNamed:@"spotLightSquare" scale:0.5]];
    
    // Start with only the directional light visible
    self.directionalLight.visible = YES;
    self.pointLight.visible = NO;
    self.spotLight.visible = NO;
    
    NSArray *lights = @[self.spotLight,self.directionalLight,self.pointLight];
    
    // Create the center node and add it to the camera wold at the same posiiton as the sphere node
    // But will rotate to move the lights around our sphere
    self.centreNode = [[ARNode alloc] init];
    self.centreNode.position = spherePosition;
    
    [self.cameraView.contentViewPort.camera addChild:self.centreNode];
    
    // Add all of our lights as children of the centre node
    for (ARLight *light in lights)
    {
        [self.centreNode addChild:light];

    }
    
    // Get access to render loop, this is so ever frame before a render will take place the view controller is sent the
    // -(void)rendererPreRender method and we can rotate the centre node each frame
    [[ARRenderer getInstance] addDelegate:self];
    
}

- (ARModelNode *)createModelNodeWithFileName:(NSString *)fileName scale:(float)scale position:(ARVector3 *)position
{
    // To import our model we need to use ARModelImporter class. To convert models into the .armodel format you must use the Kudan Toolkit
    ARModelImporter *importer = [[ARModelImporter alloc] initWithBundled:fileName];
    ARModelNode *modelNode = importer.getNode;
    modelNode.position = position;
    modelNode.scale = [ARVector3 vectorWithValues:scale];
    
    return modelNode;
}

- (ARLightMaterial *)setUpLightMaterialForModel:(ARModelNode *)model perPixel:(BOOL)perPixel
                                        ambient:(float)ambient specular:(float)specular shininess:(float)shininess reflectivity:(float)reflectivity environment:(ARTextureCube *)environment colourTexture:(ARTexture *)colourTexture normalTexture:(ARTexture *)normalTexture;
{
    // Get first mesh that is associated with the model node
    // For multi-mesh models, you would need to adjust the light material for each mesh
    ARMeshNode *mesh = (ARMeshNode *) [model.meshNodes objectAtIndex:0];
    
    // Get the light material that is associated with this mesh
    ARLightMaterial *lightMaterial = (ARLightMaterial *) mesh.material;
    
    // Set the default values of the light material
    lightMaterial.perPixelShader = perPixel;
    lightMaterial.ambient.value = [ARVector3 vectorWithValues:ambient];
    lightMaterial.specular.value = [ARVector3 vectorWithValues:specular];
    lightMaterial.shininess = shininess;
    lightMaterial.reflection.reflectivity = reflectivity;
    lightMaterial.colour.texture = colourTexture;
    lightMaterial.normal.texture = normalTexture;
    
    // Set an environment cube
    lightMaterial.reflection.environment = environment;
    
    return lightMaterial;
}

- (ARImageNode *)createImageNodeWithImageNamed:(NSString *)imageName scale:(float)scale
{
    ARImageNode *imageNode = [[ARImageNode alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageNode.scale = [ARVector3 vectorWithValues:scale];
    
    return imageNode;
}

- (ARDirectionalLight *)setUpDirectionalLightWithColour:(ARVector3 *)colour position:(ARVector3 *)position
{
    ARDirectionalLight *directionalLight = [[ARDirectionalLight alloc] initWithColour:colour];
    directionalLight.position = position;
    return directionalLight;
}

- (ARPointLight *)setUpPointLightWithColour:(ARVector3 *)colour position:(ARVector3 *)position
{
    ARPointLight *pointLight = [[ARPointLight alloc] initWithColour:colour];
    pointLight.position = position;
    return pointLight;
}

- (ARSpotLight *)setUpSpotLightWithColour:(ARVector3 *)colour innerAngle:(float)innerAngle outerAngle:(float)outerAngle position:(ARVector3 *)position
{
    ARSpotLight *spotLight = [[ARSpotLight alloc] initWithColour:colour];
    spotLight.innerSpotAngle = innerAngle;
    spotLight.outerSpotAngle = outerAngle;
    spotLight.position = position;
    
    return spotLight;
}

// Renderer delegate method
- (void)rendererPreRender
{
    // If automatic rotation is selected, rotate the centre node. This will cause the lights to rotate around the sphere
    if (_shouldRotate)
    {
        [self.centreNode rotateByDegrees:1 axisX:1 y:0 z:0];
    }
}

#pragma mark - Colour Changed Methods

// These methods change the colour of our light material to either a solid colour, or a texture file
- (IBAction)redButtonPressed:(id)sender
{
    self.lightMaterial.colour.texture = nil;
    self.lightMaterial.colour.value = [ARVector3 vectorWithValuesX:1.0 y:0 z:0];
}

- (IBAction)blueButtonPressed:(id)sender
{
    self.lightMaterial.colour.texture = nil;
    self.lightMaterial.colour.value = [ARVector3 vectorWithValuesX:0 y:0 z:1.0];
}

- (IBAction)greenButtonPressed:(id)sender
{
    self.lightMaterial.colour.texture = nil;
    self.lightMaterial.colour.value = [ARVector3 vectorWithValuesX:0 y:1.0 z:0];
}

- (IBAction)textureButtonPressed:(id)sender
{
    UIImage *myImage = [UIImage imageNamed:@"178"];
    self.lightMaterial.colour.texture = [[ARTexture alloc] initWithUIImage:myImage];
}

#pragma mark - UI event methods

// Automatic rotation switch pressed
- (IBAction)automaticRotationChanged:(UISwitch *)sender
{
    _shouldRotate = sender.on;
}


// One of the material sliders changed value, we know which one was adjusted via the tag property on the slider

- (IBAction)materialSliderChanged:(UISlider *)sender
{
    
    switch (sender.tag) {
            // Ambient slider
        case 0:
            self.lightMaterial.ambient.value = [ARVector3 vectorWithValues:sender.value];
            break;
            
            // Diffuse slider
        case 1:
            self.lightMaterial.diffuse.value = [ARVector3 vectorWithValues:sender.value];
            break;
           
            // Specular slider
        case 2:
            self.lightMaterial.specular.value = [ARVector3 vectorWithValues:sender.value];
            break;
            
            // Reflectivity slider
        case 3:
            self.lightMaterial.reflection.reflectivity = sender.value;
            break;
            
            // Shininess slider
        case 4:
            self.lightMaterial.shininess = sender.value;
            break;
    }
}

// Whether the shader is working on a per pixel, or per vertex basis
- (IBAction)perPixelChanged:(UISegmentedControl *)sender
{
    
    self.lightMaterial.perPixelShader = !sender.selectedSegmentIndex;
}

// Whether to apply a normal map (bump shading) N.B only works on Per-Pixel shading.
- (IBAction)normalMapSwitch:(UISwitch *)sender
{
    if (sender.on)
    {
        self.lightMaterial.normal.texture = [[ARTexture alloc] initWithUIImage:[UIImage imageNamed:@"178_norm"]];
    }
    else
    {
        self.lightMaterial.normal.texture = nil;
    }
}

// One of the Lighting sliders changed value
- (IBAction)lightingSliderChanged:(UISlider *)sender
{
    
    switch (sender.tag)
    {
            // Orientation Slider
        case 0:
            self.directionalLight.orientation = [ARQuaternion quaternionWithDegrees:-180 * (0.5 - sender.value) axisX:1 y:0 z:0];
            self.pointLight.orientation = [ARQuaternion quaternionWithDegrees:-180 * (0.5 - sender.value) axisX:1 y:0 z:0];
            self.spotLight.orientation = [ARQuaternion quaternionWithDegrees:-180 * (0.5 - sender.value) axisX:1 y:0 z:0];
            break;
            
            // Position Slider, it can take a value between 100 and 400
        case 1:
            self.pointLight.position.z = sender.value;
            self.spotLight.position.z = sender.value;
            break;
            
            // Attenuation Slider, it can take a value between 0 and 0.0001
        case 2:
            self.pointLight.attenuation = sender.value;
            self.spotLight.attenuation = sender.value;
            break;
            
            // Inner Spotlight Angle
        case 3:
        {
            self.spotLight.innerSpotAngle = sender.value;
            // If inner becomes more than outer, move outer to the same vale
            UISlider *outerSlider = [self.lightingView viewWithTag:4];
            if (sender.value >= outerSlider.value)
            {
                [outerSlider setValue:sender.value];
                self.spotLight.outerSpotAngle = sender.value;
            }
            break;
        }
            
            // Outer Spotlight Angle
        case 4:
            self.spotLight.outerSpotAngle = sender.value;
            // If inner becomes more than outer, move outer to the same vale
            UISlider *innerSlider = [self.lightingView viewWithTag:3];
            if (sender.value <= innerSlider.value)
            {
                [innerSlider setValue:sender.value];
                self.spotLight.innerSpotAngle = sender.value;
            }
            break;
    }
}

// Changed the type of light

- (IBAction)lightTypeChanged:(UISegmentedControl *)sender
{
    //Update the visibility of the light in our scene
    self.directionalLight.visible = NO;
    self.pointLight.visible = NO;
    self.spotLight.visible = NO;
    
    // Directional Light
    if (sender.selectedSegmentIndex == 0)
    {
        self.directionalLight.visible = YES;
    }
    
    // Point Light
    else if (sender.selectedSegmentIndex == 1)
    {
        self.pointLight.visible = YES;
    }
    
    // Spot Light
    else if (sender.selectedSegmentIndex == 2)
    {
        self.spotLight.visible = YES;
    }
    
    // Adjust slider visibility to reflect options applicable to current light type
    [self changeSliderVisibilityForLight:sender.selectedSegmentIndex];
}

- (void)changeSliderVisibilityForLight:(NSInteger)lightIndex;
{
    // Directional
    if (lightIndex == 0)
    {
        self.positionView.hidden = YES;
        self.attenuationView.hidden = YES;
        self.innerView.hidden = YES;
        self.outerView.hidden = YES;
    }
    
    // Point
    else if (lightIndex == 1)
    {
        self.positionView.hidden = NO;
        self.attenuationView.hidden = NO;
        self.innerView.hidden = YES;
        self.outerView.hidden = YES;
    }
    
    // Spot
    else if (lightIndex == 2)
    {
        self.positionView.hidden = NO;
        self.attenuationView.hidden = NO;
        self.innerView.hidden = NO;
        self.outerView.hidden = NO;
    }
}
- (IBAction)materialLightingChanged:(UISegmentedControl *)sender
{
    
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    
    for (UISegmentedControl *control in self.materialLightingSelectors) {
        control.selectedSegmentIndex = selectedIndex;
    }
    
    if (!selectedIndex)
    {
        self.materialView.hidden = NO;
        self.lightingView.hidden = YES;
    }
    else if (selectedIndex == 1)
    {
        self.materialView.hidden = YES;
        self.lightingView.hidden = NO;
    }
    else
    {
        self.materialView.hidden = YES;
        self.lightingView.hidden = YES;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        self.lightingView.hidden = YES;
    }
}

@end
