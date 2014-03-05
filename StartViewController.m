//
//  StartViewController.m
//  DVDMapToolFinal
//
//  Created by Dumitru Villceanu on 04/07/2013.
//  Copyright (c) 2013 Dumitru Villceanu. All rights reserved.
//

#import "StartViewController.h"
#import "AppDelegate.h"
#import "Street.h"

@interface StartViewController ()

- (void)configureCellForStreetsTable:(CustomCell *)cell atIndexPath:(NSIndexPath*)indexPath;

@end


@implementation StartViewController

@synthesize tableOfStreets;
@synthesize customCell;

- (void)viewDidLoad
{
    [super viewDidLoad];    
    //create general context
        
    ///~~~~~~~~~~~~~ADDED FOR FETCHING~~~~~~~~~~START
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DVDMapToolFinal" withExtension:@"momd"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"store.sqlite"];
    
    // remove old store if exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[storeURL path]])
        [fileManager removeItemAtURL:storeURL error:nil];
    
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:storeURL
                                         options:nil
                                           error:nil];
    
    // create the parent NSManagedObjectContext with the concurrency type to NSMainQueueConcurrencyType
    _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [_parentContext setPersistentStoreCoordinator:storeCoordinator];
    
    ///~~~~~~~~~~~~~ADDED FOR FETCHING~~~~~~~~~~STOP
    
    
    NSError *error = nil;
    ZAssert([[self fetchedResultsController] performFetch:&error], @"Error fetching: %@/%@", [error localizedDescription], [error userInfo]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    [self importDataFromFile];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchThroughData {  
    if (_parentContext)
    {       
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Street" inManagedObjectContext:_parentContext];
        [fetchRequest setEntity:entity];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *resultsPredicate = [NSPredicate predicateWithFormat:@"name contains [search] %@",self.searchBar.text];
        [fetchRequest setPredicate:resultsPredicate];
        
        NSError *error = nil;
        self.filteredList = [_parentContext executeFetchRequest:fetchRequest error:&error];
        if (error)
        {
            NSLog(@"Search Fetch Request failed: %@",[error localizedDescription]);
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchThroughData];
}

- (void)importDataFromFile
{
    NSString *prefixOfTheFileName = @"055759_2012-07-20_09-40_";
    NSString *localFolderPathForFile = [self folderPathFromDocumentsUsingFileName:[NSString stringWithFormat:@"%@.csv",prefixOfTheFileName]];
    BOOL fileExistsInDocuments = [[NSFileManager defaultManager] fileExistsAtPath:localFolderPathForFile];
    if(fileExistsInDocuments)
    {
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSError *error;
        NSData *dataFromFile = [NSData dataWithContentsOfFile:localFolderPathForFile options:NSDataReadingMappedAlways error:&error];
        NSString *stringFromFile = [[NSString alloc] initWithData:dataFromFile encoding:encoding];

        [self setCoreDataUsingContentOfFile:stringFromFile theSeparatorsFromLine:@"\n" or:@"\r" andSeparatorForColoumn:@","];        
        NSLog(@"mport started!File is being imported from Documents folder!");
    }
    else
    {
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSError *error;
        NSString *pathBundleForFile = [[NSBundle mainBundle] pathForResource:prefixOfTheFileName ofType:@"csv"];
        BOOL fileExistsAtMainBundle = [[NSFileManager defaultManager] fileExistsAtPath:pathBundleForFile];
        if(fileExistsAtMainBundle)
        {
            NSData *dataFromFile = [NSData dataWithContentsOfFile:pathBundleForFile options:NSDataReadingMappedAlways error:&error];
            NSString *stringFromFile = [[NSString alloc] initWithData:dataFromFile encoding:encoding];
            
            [self setCoreDataUsingContentOfFile:stringFromFile theSeparatorsFromLine:@"\n" or:@"\r" andSeparatorForColoumn:@","];
            NSLog(@"Import started!File is being imported from Main Bundle folder!");
        }
        else
        {
            NSLog(@"No file has been found!");
        }
    }
}

#pragma mark - Getting the folder for the file
- (NSString *)folderPathFromDocumentsUsingFileName:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:filename];
    return documentsDirectory;
}

- (void)setCoreDataUsingContentOfFile:(NSString *)theContentsOfTheFile  theSeparatorsFromLine:(NSString *)lineSeparator1 or:(NSString *)lineSeparator2 andSeparatorForColoumn:(NSString *)coloumnSeparator     ///getting the array of the settings from the file(content)

{
    // creat the child one with concurrency type NSPrivateQueueConcurrenyType
    _childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_childContext setParentContext:_parentContext];
    
    // create a NSEntityDescription for the only entity in this CoreData model: Street
    NSEntityDescription *testDescription = [NSEntityDescription entityForName:@"Street"
                                                       inManagedObjectContext:_parentContext];
    
    NSArray *arrayOfAllLinesSeparatedUsingFirstSeparator = [theContentsOfTheFile componentsSeparatedByString:lineSeparator1];
    NSMutableArray *arrayOfAllLines = [[[NSArray alloc]initWithArray:arrayOfAllLinesSeparatedUsingFirstSeparator]mutableCopy];

    if([arrayOfAllLines count] > 0) {
        //Remove first line from the CSV. - header of the CSV file
        [arrayOfAllLines removeObjectAtIndex:0]; 
        
        // perform a heavy write block on the child context
        __block BOOL done = NO;
        [_childContext performBlock:^{
            
            int idOfStreet = 0;
            for (NSString * oneLineString in arrayOfAllLines)
            {
                NSArray *arrayOfElementsFromALine = [oneLineString componentsSeparatedByString:lineSeparator2];
                NSString *actuatTextFromALine = [arrayOfElementsFromALine objectAtIndex:0];
                
                NSArray *theArrayFromALine = [actuatTextFromALine componentsSeparatedByString:coloumnSeparator];
                if ([theArrayFromALine count] != 0)
                {
                    if([theArrayFromALine count] == 1)
                    {
                        //currentSection = [theArrayFromALine objectAtIndex:0];
                    }
                    if ([theArrayFromALine count] == 3)
                    {
                        NSString *streetName = [theArrayFromALine objectAtIndex:1];
                        NSString *streetCoordinate = [theArrayFromALine objectAtIndex:2];
                        NSString *strIdOfStreet = [NSString stringWithFormat:@"%d",idOfStreet];
                        idOfStreet ++;
                        NSString *firstLetter = [streetName substringToIndex:1];
                        Street *streetInstance = [[Street alloc] initWithEntity:testDescription
                                   insertIntoManagedObjectContext:_childContext];
                        streetInstance.name = streetName;
                        streetInstance.mapIndex = streetCoordinate;
                        streetInstance.idOfStreet = strIdOfStreet;
                        streetInstance.firstLetter = firstLetter;
                        //NSLog(@"Created street nr: %@ having name:%@ with coordinate: %@",strIdOfStreet, streetName,streetCoordinate);
                        
                        [_childContext save:nil];
                    }
                }
            }
            
            
            done = YES;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"Done write test: Saving parent");
                [_parentContext save:nil];
                
                // execute a fetch request on the parent to see the results
                NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Street"];
                NSLog(@"Done: %d objects written", [[_parentContext executeFetchRequest:fr error:nil] count]);
                //fetchedResultsController = [self fetchedResultsController];
            });
        }];
        
        // execute a read request after 1 second
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Street"];
            [_parentContext performBlockAndWait:^{
                NSLog(@"In between read: read %d objects", [[_parentContext executeFetchRequest:fr error:nil] count]);
            }];
        });
        
    }
    
}

#pragma mark - Applications Documents Directory
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)contextChanged:(NSNotification*)notification
{
    if ([notification object] == _parentContext) return;
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    [_parentContext mergeChangesFromContextDidSaveNotification:notification];
}

#pragma mark -
#pragma mark Table view data source

- (void)configureCellForStreetsTable:(CustomCell *)cell atIndexPath:(NSIndexPath*)indexPath;
{
    id object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [cell.lblStreetName setText:[object valueForKey:@"name"]];
    [cell.lblIdOfStreet setText:[object valueForKey:@"idOfStreet"]];
    [cell.lblMapIndex setText:[object valueForKey:@"mapIndex"]];
}


- (void)configureCellForSearchResultsTable:(CustomCell *)cell atIndexPath:(NSIndexPath*)indexPath;
{  
    Street *object = [self.filteredList objectAtIndex:indexPath.row];
    
    [cell.lblStreetName setText:[object valueForKey:@"name"]];
    [cell.lblIdOfStreet setText:[object valueForKey:@"idOfStreet"]];
    [cell.lblMapIndex setText:[object valueForKey:@"mapIndex"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (tableView == tableOfStreets) {
        return [[fetchedResultsController sections] count];
    } else {
        return  1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == tableOfStreets) {
        return [[[fetchedResultsController sections] objectAtIndex:section] name];
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == tableOfStreets) {
        id sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return [self.filteredList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"MyCellIdentifier";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (tableView == tableOfStreets) {
        [self configureCellForStreetsTable:cell atIndexPath:indexPath];
    } else {
        [self configureCellForSearchResultsTable:cell atIndexPath:indexPath];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = nil;
    if (tableView == tableOfStreets) {
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    } else{
        object = [self.filteredList objectAtIndex:indexPath.row];
    }
    
    NSString *mapStoryboardName = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        mapStoryboardName = @"MapStoryboard_iPad";
    } else {
        mapStoryboardName = @"MapStoryboard_iPhone";
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:mapStoryboardName bundle:nil];
    AreaOfMapViewController *mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"AreaOfMap"];
    mapViewController.streetCoordinate = [object valueForKey:@"mapIndex"];
    [self presentViewController:mapViewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //automated deselect the cell that has been selected
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController*)fetchedResultsController
{
    if (fetchedResultsController) return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Street" inManagedObjectContext:_parentContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_parentContext sectionNameKeyPath:@"firstLetter" cacheName:@"Root"];
    fetchedResultsController.delegate = self;
   
    return fetchedResultsController;
}

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self.tableOfStreets beginUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableOfStreets insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableOfStreets deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    
    UITableView *tableViewLocal = self.tableOfStreets;
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [tableViewLocal insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableViewLocal deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCellForStreetsTable:(CustomCell *)[tableViewLocal cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableViewLocal deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableViewLocal insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller 
{
    [self.tableOfStreets endUpdates];
}

@end
