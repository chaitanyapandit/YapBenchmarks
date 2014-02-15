//
//  ITYapDatabaseViewController.m
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 14/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "ITYapDatabaseViewController.h"
#import "ITAppDelegate.h"
#import "YAPPerson.h"
#import "ITTableViewCell.h"

@interface ITYapDatabaseViewController ()

@end

@implementation ITYapDatabaseViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initializeDb];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[ITTableViewCell class] forCellReuseIdentifier:@"core.data"];
    [self updateTitle:@"YapDatabase"];
}

- (void)updateTitle:(NSString *)title
{
    self.navigationItem.title = title;
}

- (IBAction)load:(id)sender
{
    CGFloat insertionTime = 0.0f;
    
    NSDate *referenceDate = [NSDate date];
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dummy" ofType:@"json"]];
    NSArray *people = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"%@", [NSString stringWithFormat:@"Loaded people in %f sec", [[NSDate date] timeIntervalSinceDate:referenceDate]]);
    
    referenceDate = [NSDate date];
    [self insertPeople:people];
  
    insertionTime = [[NSDate date] timeIntervalSinceDate:referenceDate];
    NSString *log = [NSString stringWithFormat:@"Insertions took %f sec", insertionTime];
    NSLog(@"%@", log);
    
    referenceDate = [NSDate date];
    
    log = [NSString stringWithFormat:@"Took %f sec", insertionTime];
    NSLog(@"%@", log);
    [self updateTitle:log];
}

- (void)insertPeople:(NSArray *)people
{
    [self.dbConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        [people enumerateObjectsUsingBlock:^(NSDictionary *info, NSUInteger idx, BOOL *stop) {
            
            YAPPerson *person = [[YAPPerson alloc] init];
            [person updateWithInfo:info];

            [transaction setObject:person forKey:person.udid inCollection:@"people"];
            NSString *log = [NSString stringWithFormat:@"Inserted %d of %d", idx, people.count];
            NSLog(@"%@", log);
        }];
    }];
}

- (NSString *)databaseName
{
	return @"YapDatabase.sqlite";
}

- (NSString *)databasePath
{
	return [[[[ITAppDelegate sharedInstance] applicationDocumentsDirectory] absoluteString] stringByAppendingPathComponent:[self databaseName]];
}

- (void)initializeDb
{
    self.db = [[YapDatabase alloc] initWithPath:[self databasePath]];
    self.dbConnection = [self.db newConnection];
    self.dbConnection.objectCacheLimit = 1000; // Most of the messages are maintained in the app
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, YAPPerson *person){
        
        return collection; // The group name is the name of the collection
    };
    
    YapDatabaseViewSortingWithObjectBlock sortingBlock = sortingBlock = ^(NSString *group, NSString *collection1, NSString *key1, YAPPerson *person1, NSString *collection2, NSString *key2, YAPPerson *person2){
        
        return [person1.name compare:person2.name];
    };
    
    self.dbView = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock groupingBlockType:YapDatabaseViewBlockTypeWithObject sortingBlock:sortingBlock sortingBlockType:YapDatabaseViewBlockTypeWithObject];
}

@end
