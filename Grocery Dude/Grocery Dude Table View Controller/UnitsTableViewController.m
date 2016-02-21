//
//  UnitsViewController.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/19.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "UnitsTableViewController.h"
#import "AppDelegate.h"
#import "Unit+CoreDataProperties.h"

@interface UnitsTableViewController ()

@end

@implementation UnitsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - *** Helper ***
- (void)configureFetch
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [request setFetchBatchSize:50];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - *** Table View Data Source***
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Units Cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - *** TableView Delegate ***
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Unit* unit = [self.frc objectAtIndexPath:indexPath];
    
    cell.textLabel.text = unit.name;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        Unit* targetObj = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:targetObj];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - ***Target Action ***

- (IBAction)done:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
