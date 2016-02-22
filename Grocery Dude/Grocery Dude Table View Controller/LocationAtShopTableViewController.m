//
//  LocationAtShopViewController.m
//  Grocery Dude
//
//  Created by birneysky on 16/2/21.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "LocationAtShopTableViewController.h"
#import "AppDelegate.h"
#import "LocationAtShop+CoreDataProperties.h"
#import "LocationAtShopViewController.h"

@interface LocationAtShopTableViewController ()

@end

@implementation LocationAtShopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                    selector:@selector(performFetch)
                                       name:@"SomethingChanged"
                                        object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark - ***Helper ***
- (void)configureFetch
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES]];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
}


#pragma mark - ***Target Action ***
- (IBAction)done:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - *** TableView DataSource ***
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationAtShop Cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - ***TableView Delegate ***
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationAtShop* locationAtShop = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = locationAtShop.aisle;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LocationAtShopViewController* lasVc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Object Segue"]) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        LocationAtShop* newLocationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
        NSError* error = nil;
        if ([cdh.context obtainPermanentIDsForObjects:@[newLocationAtShop] error:&error]) {
            DebugLog(@"Could't obtain a permanetn ID for objects:%@",error);
        }
        lasVc.selectItemID = [newLocationAtShop objectID];
    }
    else if ([segue.identifier isEqualToString:@"Edit Object Segue"]){
        NSIndexPath* selectIndexPath = [self.tableView indexPathForSelectedRow];
        LocationAtShop* locationAtShop = [self.frc objectAtIndexPath:selectIndexPath];
        lasVc.selectItemID = [locationAtShop objectID];
    }
    else
    {
        TRACE(@"Unidentified segue attemped!");
    }
}


@end
