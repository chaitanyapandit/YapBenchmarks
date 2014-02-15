//
//  ITCoreDatatViewController.m
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 14/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "ITCoreDatatViewController.h"
#import "ITAppDelegate.h"
#import "Person.h"
#import "ITTableViewCell.h"

@interface ITCoreDatatViewController ()

@end

@implementation ITCoreDatatViewController

- (NSManagedObjectContext *)managedObjectContext
{
    return [[ITAppDelegate sharedInstance] managedObjectContext];
}

- (void)updateTitle:(NSString *)title
{
    self.navigationItem.title = title;
}

- (IBAction)load:(id)sender
{
    CGFloat insertionTime = 0.0f;
    CGFloat saveTime = 0.0f;

    NSDate *referenceDate = [NSDate date];
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dummy" ofType:@"json"]];
    NSArray *people = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"%@", [NSString stringWithFormat:@"Loaded people in %f sec", [[NSDate date] timeIntervalSinceDate:referenceDate]]);

    referenceDate = [NSDate date];
    
    [people enumerateObjectsUsingBlock:^(NSDictionary *info, NSUInteger idx, BOOL *stop) {
      
        [self insertPersonWithInfo:info];
        NSString *log = [NSString stringWithFormat:@"Inserted %d of %d", idx, people.count];
        NSLog(@"%@", log);
    }];
    
    insertionTime = [[NSDate date] timeIntervalSinceDate:referenceDate];
    NSString *log = [NSString stringWithFormat:@"Insertions took %f sec", insertionTime];
    NSLog(@"%@", log);
    
    referenceDate = [NSDate date];
    [self save];
    saveTime = [[NSDate date] timeIntervalSinceDate:referenceDate];
    log = [NSString stringWithFormat:@"Saving took %f sec", saveTime];
    NSLog(@"%@", log);

    log = [NSString stringWithFormat:@"Took %f sec", insertionTime+saveTime];
    NSLog(@"%@", log);
    [self updateTitle:log];
}

- (Person *)insertPersonWithInfo:(NSDictionary *)personInfo
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [person updateWithInfo:personInfo];
    
    return person;
}

- (void)save
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];

    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[ITTableViewCell class] forCellReuseIdentifier:@"core.data"];
    [self.searchDisplayController.searchResultsTableView registerClass:[ITTableViewCell class] forCellReuseIdentifier:@"core.data"];
    [self updateTitle:@"Core Data"];
}

#pragma mark - Search

-(void)filter:(NSString*)text
{
    NSDate *referenceDate = [NSDate date];

    // Create our fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Define the entity we are looking for
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Define how we want our entities to be sorted
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // If we are searching for anything...
    if(text.length > 0)
    {
        // Define how we want our entities to be filtered
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@) OR (about CONTAINS[c] %@)", text, text];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    
    // Finally, perform the load
    NSArray* loadedEntities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSString *log = [NSString stringWithFormat:@"Search took %f sec", [[NSDate date] timeIntervalSinceDate:referenceDate]];
    NSLog(@"%@", log);

    self.searchResults = [[NSMutableArray alloc] initWithArray:loadedEntities];
    
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self filter:text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.searchResults = nil;
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (tableView == self.tableView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        rows = [sectionInfo numberOfObjects];
    }
    else
        rows = self.searchResults.count;
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"core.data" forIndexPath:indexPath];

    NSManagedObject *object = nil;
    if (tableView == self.tableView)
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    else
        object = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[object valueForKey:@"name"] description];
    cell.detailTextLabel.text = [[object valueForKey:@"about"] description];

    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
     // In the simplest, most efficient, case, reload the table view.
     [self.tableView reloadData];
 }



@end
