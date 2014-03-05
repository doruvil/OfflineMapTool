//
//  Street.h
//  DVDMapToolFinal
//
//  Created by Lion User on 06/07/2013.
//  Copyright (c) 2013 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Street : NSManagedObject

@property (nonatomic, retain) NSString * idOfStreet;
@property (nonatomic, retain) NSString * mapIndex;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * firstLetter;

@end
