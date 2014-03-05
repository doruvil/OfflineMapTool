//
//  CustomCell.h
//
//  Created by Dumitru Villceanu on 04/07/13.
//  Copyright (c) 2013 Dumitru Villceanu All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
{}
@property (weak, nonatomic) IBOutlet UILabel *lblStreetName;
@property (weak, nonatomic) IBOutlet UILabel *lblMapIndex;
@property (weak, nonatomic) IBOutlet UILabel *lblIdOfStreet;


@end
