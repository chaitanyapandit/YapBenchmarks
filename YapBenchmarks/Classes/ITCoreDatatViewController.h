//
//  ITCoreDatatViewController.h
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 14/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ITCoreDatatViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (IBAction)load:(id)sender;

@end
