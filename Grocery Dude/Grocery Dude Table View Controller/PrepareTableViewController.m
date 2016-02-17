//
//  PrepareTableViewController.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/16.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "PrepareTableViewController.h"
#import "AppDelegate.h"
#import "Item+CoreDataProperties.h"
#import "ItemViewController.h"

@interface PrepareTableViewController () <UIActionSheetDelegate>

@property (nonatomic,strong) UIActionSheet* clearConfirmActionSheet;

@end

@implementation PrepareTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    self.clearConfirmActionSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
}




- (void)configureFetch{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"locationAtHome.storedin" ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    //操作依照指定的大小来分批处理
    [request setFetchBatchSize:50];
    /*创建NSFetchedResultsController 需要有四样东西
        1.NSFetchRequest 实例
        2.NSManagedObjectContext 托管上下文实例
        3.sectionNameKeyPath，该字符串值是托管实体中某个属性的key，它用于讲tableview划分成不同的部分，
          locationAtHome.storedIn意思是按照货品在家中摆放的位置来将表格划分成不同部分，注意改制必须与sortDescriptors所使用的值相符.
        4.表示缓存字符串，虽说本例并未提供该字符串，如果使用，就得保证该字符串在整个应用程序范围内是唯一的。
     */
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtHome.storedin" cacheName:nil];
    self.frc.delegate = self;
}


#pragma mark - *** TableView DataSource ***

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Item Cell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item* item = [self.frc objectAtIndexPath:indexPath];
    
    NSMutableString* title = [NSMutableString stringWithFormat:@"%@%@ %@",item.quantity,item.unit.name,item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, [title length])];
    cell.textLabel.text = title;
    
    if ([item.listed boolValue]) {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    else
    {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        cell.textLabel.textColor = [UIColor grayColor];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        Item* deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectID* itemId = [[self.frc objectAtIndexPath:indexPath] objectID];
    
    Item* item = [self.frc.managedObjectContext existingObjectWithID:itemId error:nil];
    if ([item.listed boolValue]) {
        item.listed = [NSNumber numberWithBool:NO];
    }
    else
    {
        item.listed = [NSNumber numberWithBool:YES];
        item.collected = [NSNumber numberWithBool:NO];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - *** Target Action ***
- (IBAction)clear:(id)sender {
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray* shoppingList = [cdh.context executeFetchRequest:request error:nil];
    if (shoppingList.count > 0) {
        self.clearConfirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Clear Entire Shopping List ?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:@"Clear"
                                                          otherButtonTitles:nil];
        [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    }
    else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Clear" message:@"Add items to the Shop tab by tapping them on the prepare tab. Remvoe all items from the shop" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    shoppingList = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.clearConfirmActionSheet) {
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            [self performSelector:@selector(clearList)];
        }
    }
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
    }
}

- (void)clearList
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    
    NSFetchRequest* request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray* shoppingList = [cdh.context executeFetchRequest:request error:nil];
    [shoppingList makeObjectsPerformSelector:@selector(setListed:) withObject:[NSNumber numberWithBool:NO]];
}


#pragma mark - *** Segue ***

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ItemViewController* itemVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Item Segue"]) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        Item* newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
        NSError* error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:@[newItem] error:&error]) {
            DebugLog(@"Couldn't obtain a permanent ID for object %@",error);
        }
        itemVC.selectedItemID = newItem.objectID;
    }
    else if ([segue.identifier isEqualToString:@"Show Item Segue"])
    {
        NSIndexPath* indexpath = [self.tableView indexPathForCell:sender];
        itemVC.selectedItemID = [[self.frc objectAtIndexPath:indexpath] objectID];
    }
    
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    ItemViewController* itemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemVC"];
//    itemVC.selectedItemID = [[self.frc objectAtIndexPath:indexPath] objectID];
//    [self.navigationController pushViewController:itemVC animated:YES];
    //self.hidesBottomBarWhenPushed = YES;
}

@end
