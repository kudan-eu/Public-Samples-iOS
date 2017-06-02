//
//  TitleViewController.m
//  Sample Code - ObjC
//
//  Copyright © 2017 Kudan. All rights reserved.
//

#import "TitleViewController.h"

@interface TitleViewController ()

@property (nonatomic) NSArray *viewControllers;

@end

@implementation TitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewControllers = @[@"Extracted Camera",@"Panorama",@"Marker To Markerless",@"Multiple Marker",@"Marker"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.text = self.viewControllers[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    
    UIViewController *vC = [storyboard instantiateViewControllerWithIdentifier:self.viewControllers[indexPath.row]];
    
    vC.title = self.viewControllers[indexPath.row];

    [self.navigationController pushViewController:vC animated:YES];
}

@end
