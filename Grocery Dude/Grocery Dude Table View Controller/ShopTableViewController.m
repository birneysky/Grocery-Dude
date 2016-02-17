//
//  ShopTableViewController.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/17.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "ShopTableViewController.h"
#import "AppDelegate.h"
#import "Item+CoreDataProperties.h"

@interface ShopTableViewController ()

@end

@implementation ShopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
}

- (void)configureFetch{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    /*
     注意NSFetchedResultsController使用的不是请求模板本身，而是它的一份拷贝，之所以这样做，是因为我们要通过修改NSFetchRequeest来
     指定NSSortDescriptor，但是获取请求模板却不能直接编辑，所以只能先拷贝一份，然后在拷贝出来的NSFetchRequeest上面修改。
     
     */
    NSFetchRequest* request = [[cdh.model fetchRequestTemplateForName:@"ShoppingList"] copy];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locationAtShop.aisle" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [request setFetchBatchSize:50];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtShop.aisle" cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - *** Data Source ***
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Shop Cell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item* item =[self.frc objectAtIndexPath:indexPath];
    NSMutableString* title = [NSMutableString stringWithFormat:@"%@%@ %@",item.quantity,item.unit.name,item.name];
    cell.textLabel.text = title;
    
    if (item.collected.boolValue) {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        cell.textLabel.textColor = [UIColor colorWithRed:0.368 green:0.741 blue:0.349 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Nenu" size:18];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item* item = [self.frc objectAtIndexPath:indexPath];
    
    if (item.collected.boolValue) {
        item.collected = @(NO);
    }
    else{
        item.collected = @(YES);
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - *** Target Action ***

- (IBAction)clear:(id)sender {
    
    if (self.frc.fetchedObjects.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Clear"
                                                        message:@"Add items using the Prepare tab"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BOOL notingCleared = YES;
    for (Item* item in self.frc.fetchedObjects) {
        if (item.collected.boolValue) {
            item.listed = @(NO);
            item.collected = @(NO);
            notingCleared = NO;
        }
    }
    
    if (notingCleared) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Select items to be removed from the list before pressing clear"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


@end
