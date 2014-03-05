//
//  StartViewController.h
//  DVDMapToolFinal
//
//  Created by Dumitru Villceanu on 04/07/2013.
//  Copyright (c) 2013 Dumitru Villceanu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomCell.h"
#import "AreaOfMapViewController.h"
@class CustomCell;
@class AreaOfMapViewController;
@interface StartViewController : UIViewController <UITextFieldDelegate,NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    dispatch_queue_t mConcurrentQueue;
    
    NSManagedObjectContext *_parentContext;     // parent managedObjectContext tied to the persistent store coordinator
    NSManagedObjectContext *_childContext;      // child managedObjectContext whichs runs in a background thread
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet CustomCell *customCell;
@property (nonatomic, strong) IBOutlet UITableView *tableOfStreets;


@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) NSArray *filteredList;


@end
