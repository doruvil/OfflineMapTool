//
//  AreaOfMapViewController.h
//  DVDMapTool
//
//  Created by Dumitru Villceanuon 04/07/2013.
//  Copyright (c) 2013 Dumitru Villceanu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaOfMapViewController : UIViewController<UIScrollViewDelegate> 
{
    CGFloat widthOfImage;
    CGFloat heightOfImage;
    
    NSDecimalNumber *decWidthOfBlock;
    NSDecimalNumber *decHeightOfBlock;
    
    NSDecimalNumber *decWidthOfTheScrollView;
    NSDecimalNumber *decHeightOfTheSCrollView;
    
    
    NSMutableArray *elementsOfWidth;
    NSMutableArray *elementsOfHeight;
    
    float scaleValueAccordingToAreaWidth;
    float scaleValueAccordingToAreaHeight;
    
    CGRect scrollViewBounds;
    CGRect scrollViewFrame;
    
    CGRect screenRect;
    
    NSUInteger lastOrientation;
}
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign) NSString *streetCoordinate;

- (IBAction)dismissTheViewAction:(id)sender;

@end
