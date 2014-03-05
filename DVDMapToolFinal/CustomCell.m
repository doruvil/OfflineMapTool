//
//  CustomCell.m
//
//  Created by Dumitru Villceanu on 04/07/13.
//  Copyright (c) 2013 Dumitru Villceanu. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize lblStreetName = _lblStreetName;
@synthesize lblMapIndex = _lblMapIndex;
@synthesize lblIdOfStreet = _lblIdOfStreet;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

@end
