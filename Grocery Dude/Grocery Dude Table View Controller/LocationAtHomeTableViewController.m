//
//  LocationAtHomeViewController.m
//  Grocery Dude
//
//  Created by birneysky on 16/2/21.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "LocationAtHomeTableViewController.h"
#import "AppDelegate.h"
#import "LocationAtHome+CoreDataProperties.h"
#import "LocationAtHomeViewController.h"


@interface LocationAtHomeTableViewController ()

@end

@implementation LocationAtHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                     selector:@selector(performFetch)
                                        name:@"SomethingChanged"
                                      object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ***Helper ***
- (void)configureFetch
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request  = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"storedin" ascending:YES]];
    [request setFetchBatchSize:50];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
    
}

#pragma mark - *** Target Action ***
- (IBAction)done:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - *** TableView Data Source ***

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationAtHome Cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - ***TableView Delegate ***
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationAtHome* locationAtHome = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = locationAtHome.storedin;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LocationAtHomeViewController* lahVC = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"Add Object Segue"]) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        LocationAtHome* locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
        NSError* error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:@[locationAtHome] error:&error]) {
            DebugLog(@"Could't obtain a permanent id for Objets:%@",error);
        }
        lahVC.selectItemID = [locationAtHome objectID];
    }
    else if ([segue.identifier isEqualToString:@"Edit Object Segue"]){
        NSIndexPath* selectIndexPath = [self.tableView indexPathForSelectedRow];
        LocationAtHome* locationAtHome = [self.frc objectAtIndexPath:selectIndexPath];
        lahVC.selectItemID = [locationAtHome objectID];
    }
    else
    {
        TRACE(@"Unidentified segue attemp!");
    }
}


@end
