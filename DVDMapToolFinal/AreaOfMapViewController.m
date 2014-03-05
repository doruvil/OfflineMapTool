
//
//  AreaOfMapViewController.m
//  DVDMapTool
//
//  Created by Dumitru Villceanu on 04/07/2013.
//  Copyright (c) 2013 Dumitru Villceanu. All rights reserved.
//

#import "AreaOfMapViewController.h"
static int XCoordType = 1;
static int YCoordType = 2;
static BOOL certainArea = FALSE;
@interface AreaOfMapViewController ()

@end


@implementation AreaOfMapViewController
@synthesize scrollView;
@synthesize imageView;
@synthesize btnBack;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    scrollViewBounds = self.scrollView.bounds;
    [scrollView setBounds:self.view.bounds];
    scrollViewFrame = self.scrollView.frame;
    screenRect = [[UIScreen mainScreen] bounds];
    lastOrientation = UIInterfaceOrientationPortrait;
    
    
    if (self.streetCoordinate)
    {
        certainArea = TRUE;
    }
    elementsOfWidth =  [[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",
                        @"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"AA",@"AB",nil];
    
    elementsOfHeight = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",
                        @"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",nil];
    NSAssert(self.scrollView, @"self.scrollView must not be nil."
             "Check your IBOutlet connections.");
    NSAssert(self.imageView, @"self.imageView must not be nil."
             "Check your IBOutlet connections.");
      
    [self configureGraphicalInterface];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)configureGraphicalInterface
{
    UIImage* image = [UIImage imageNamed:@"map"];
    widthOfImage = image.size.width;
    heightOfImage = image.size.height;
    NSAssert(image, @"image must not be nil."
             "Check that you added the image to your bundle and that "
             "the filename above matches the name of your image.");
    
    float widthOfTheScrollView = self.scrollView.bounds.size.width;
    float heightOfTheScrollView = self.scrollView.bounds.size.height;
    
    decWidthOfTheScrollView = [[NSDecimalNumber alloc] initWithFloat:widthOfTheScrollView];
    decHeightOfTheSCrollView = [[NSDecimalNumber alloc] initWithFloat:heightOfTheScrollView];
    
    NSDecimalNumber *decWidthOfImage = [[NSDecimalNumber alloc] initWithFloat:widthOfImage];
    NSDecimalNumber *decNumberOfColoumns = [[NSDecimalNumber alloc] initWithInt:28];
    decWidthOfBlock = [decWidthOfImage decimalNumberByDividingBy:decNumberOfColoumns];
    
    NSDecimalNumber *decHeightOfImage = [[NSDecimalNumber alloc] initWithFloat:heightOfImage];
    NSDecimalNumber *decNumberOfLines = [[NSDecimalNumber alloc] initWithInt:27];
    decHeightOfBlock = [decHeightOfImage decimalNumberByDividingBy:decNumberOfLines];
    
    self.imageView.image = image;
    [self.imageView sizeToFit];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.1; // it should be less than 1 in order to accomplish zoom out
    self.scrollView.maximumZoomScale = 100.0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect scrollTempBounds = self.scrollView.bounds;
    CGRect scrollTempFrame = self.scrollView.frame;
    
    CGPoint centerPointWhichWasSet;
    CGPoint pointRelativeToLeftCorner;
    CGPoint newCenterToSet;
    
    float zoomScaleToSetAfter;
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"Portrait orientation set");
            if ((! CGRectEqualToRect(scrollTempBounds,scrollViewBounds) || ! CGRectEqualToRect(scrollTempFrame, scrollViewFrame)) && (!(lastOrientation == UIInterfaceOrientationPortrait || lastOrientation == UIInterfaceOrientationPortraitUpsideDown)))
            {
                zoomScaleToSetAfter = self.scrollView.zoomScale;
                [self.scrollView setZoomScale:1];                
                CGPoint centerPointWhichWasSet = [self retrieveCenterPointUsingView:self.imageView andCurrentOffset:self.scrollView.contentOffset];
                CGPoint pointRelativeToLeftCorner = [self convertCenterPointToLocationRegardinTheLefUpperCorner:centerPointWhichWasSet orientationPortrait:TRUE];
                [self.scrollView setBounds:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
                [self.scrollView setFrame:CGRectMake(0,0, screenRect.size.width, screenRect.size.height)];
                CGPoint newCenterToSet = [self getNewCenterPointUsingRelativePoint:pointRelativeToLeftCorner];
                [self view:self.imageView setCenter:newCenterToSet];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1];
                [self.scrollView setZoomScale:zoomScaleToSetAfter animated:YES];
                [UIView commitAnimations];
                lastOrientation  = UIInterfaceOrientationPortrait;
            }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"PortraitUpsideDown orientation set");
            if ((! CGRectEqualToRect(scrollTempBounds,scrollViewBounds) || ! CGRectEqualToRect(scrollTempFrame, scrollViewFrame)) && (!(lastOrientation == UIInterfaceOrientationPortrait || lastOrientation == UIInterfaceOrientationPortraitUpsideDown)))
            {
                zoomScaleToSetAfter = self.scrollView.zoomScale;
                [self.scrollView setZoomScale:1];
                CGPoint centerPointWhichWasSet = [self retrieveCenterPointUsingView:self.imageView andCurrentOffset:self.scrollView.contentOffset];
                CGPoint pointRelativeToLeftCorner = [self convertCenterPointToLocationRegardinTheLefUpperCorner:centerPointWhichWasSet orientationPortrait:TRUE];
                [self.scrollView setBounds:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
                [self.scrollView setFrame:CGRectMake(0,0, screenRect.size.width, screenRect.size.height)];
                CGPoint newCenterToSet = [self getNewCenterPointUsingRelativePoint:pointRelativeToLeftCorner];
                [self view:self.imageView setCenter:newCenterToSet];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1];
                [self.scrollView setZoomScale:zoomScaleToSetAfter animated:YES];
                [UIView commitAnimations];
                lastOrientation  = UIInterfaceOrientationPortraitUpsideDown;
            }
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
                NSLog(@"LandscapeLeft orientation set");
            if (!(lastOrientation == UIInterfaceOrientationLandscapeLeft || lastOrientation == UIInterfaceOrientationLandscapeRight))
            {
                zoomScaleToSetAfter = self.scrollView.zoomScale;
                [self.scrollView setZoomScale:1];
                centerPointWhichWasSet = [self retrieveCenterPointUsingView:self.imageView andCurrentOffset:self.scrollView.contentOffset];
                pointRelativeToLeftCorner = [self convertCenterPointToLocationRegardinTheLefUpperCorner:centerPointWhichWasSet orientationPortrait:FALSE];
                [self.scrollView setBounds:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                [self.scrollView setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
                newCenterToSet = [self getNewCenterPointUsingRelativePoint:pointRelativeToLeftCorner];
                [self view:self.imageView setCenter:newCenterToSet];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1];
                [self.scrollView setZoomScale:zoomScaleToSetAfter animated:YES];
                [UIView commitAnimations];
                
                lastOrientation  = UIInterfaceOrientationLandscapeLeft;
            }
            

            break;
            
        case UIInterfaceOrientationLandscapeRight:
                NSLog(@"LandscapeRight orientation set");
            if (!(lastOrientation == UIInterfaceOrientationLandscapeLeft || lastOrientation == UIInterfaceOrientationLandscapeRight))
            {
                zoomScaleToSetAfter = self.scrollView.zoomScale;
                [self.scrollView setZoomScale:1];
                centerPointWhichWasSet = [self retrieveCenterPointUsingView:self.imageView andCurrentOffset:self.scrollView.contentOffset];
                pointRelativeToLeftCorner = [self convertCenterPointToLocationRegardinTheLefUpperCorner:centerPointWhichWasSet orientationPortrait:FALSE];
                [self.scrollView setBounds:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                [self.scrollView setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
                newCenterToSet = [self getNewCenterPointUsingRelativePoint:pointRelativeToLeftCorner];
                [self view:self.imageView setCenter:newCenterToSet];
            
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1];
                [self.scrollView setZoomScale:zoomScaleToSetAfter animated:YES];
                [UIView commitAnimations];
                lastOrientation  = UIInterfaceOrientationLandscapeRight;
            }
            break;
            
        default:
            break;
    }
    [self configureGraphicalInterface];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.imageView = nil;
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureCenterForTheImageView];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
}

- (void)configureCenterForTheImageView
{
    NSString *startCoordinate = @"";
    NSString *stopCoordinate = @"";
    NSArray *arrayOfElementsFromString = [self.streetCoordinate componentsSeparatedByString:@"-"];
    if ([arrayOfElementsFromString count]==1)
    {
        startCoordinate = [arrayOfElementsFromString objectAtIndex:0];
        stopCoordinate = [arrayOfElementsFromString objectAtIndex:0];
    }
    if ([arrayOfElementsFromString count]==2) {
        startCoordinate = [arrayOfElementsFromString objectAtIndex:0];
        stopCoordinate = [arrayOfElementsFromString objectAtIndex:1];
    }
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    if (certainArea)
    {
        centerPoint = [self getCenterPointForCoordinatesStart:startCoordinate coordinatesStop:stopCoordinate];
    }
    [self view:self.imageView setCenter:centerPoint];
    
    if (certainArea) {
        [self setNewValueForZoomUsingXAxisScaleValue:scaleValueAccordingToAreaWidth andYAxisScaleValue:scaleValueAccordingToAreaHeight];
    }
    [self.view addSubview:btnBack];
    
    scrollViewBounds = self.scrollView.bounds;
    scrollViewFrame = self.scrollView.frame;
}

- (void)setNewValueForZoomUsingXAxisScaleValue:(float)XAxisScaleValue andYAxisScaleValue:(float)YAxisScaleValue
{
    if (XAxisScaleValue < YAxisScaleValue)
    {
        [self.scrollView setZoomScale:XAxisScaleValue animated:YES];
    }
    else
    {
        [self.scrollView setZoomScale:YAxisScaleValue animated:YES];
    }
}

- (CGPoint)getCenterPointForCoordinatesStart:(NSString *)startCoordinate coordinatesStop:(NSString *)stopCoordinate
{
    if ([startCoordinate length]==0 || [stopCoordinate length]==0) {
        return CGPointMake(CGRectGetMidX(self.scrollView.bounds),CGRectGetMidY(self.scrollView.bounds));
    }
    int lengthOfLetterCoordinate = [self getLengthOfLetterCoordinateFrom:startCoordinate];
    NSString *wXStart = [self getSubstringFromActualSring:startCoordinate usingStartPoint:0 andTheLength:lengthOfLetterCoordinate];
    NSString *hYStart = [self getSubstringFromActualSring:startCoordinate usingStartPoint:lengthOfLetterCoordinate andTheLength:[startCoordinate length]-lengthOfLetterCoordinate];
    
    lengthOfLetterCoordinate = [self getLengthOfLetterCoordinateFrom:stopCoordinate];
    NSString *wXStop = [self getSubstringFromActualSring:stopCoordinate usingStartPoint:0 andTheLength:lengthOfLetterCoordinate];
    NSString *hYStop = [self getSubstringFromActualSring:stopCoordinate usingStartPoint:lengthOfLetterCoordinate andTheLength:[stopCoordinate length]-lengthOfLetterCoordinate];
    
    BOOL coordinatesFormatOK = TRUE;
    if (![self checkCoordinateAccordingToTheGridUsingCoordinateValue:wXStart andCoordinateType:XCoordType]) {
        coordinatesFormatOK = FALSE;
    }
    if (![self checkCoordinateAccordingToTheGridUsingCoordinateValue:hYStart andCoordinateType:YCoordType]) {
        coordinatesFormatOK = FALSE;
    }
    if (![self checkCoordinateAccordingToTheGridUsingCoordinateValue:wXStop andCoordinateType:XCoordType]) {
        coordinatesFormatOK = FALSE;
    }
    if (![self checkCoordinateAccordingToTheGridUsingCoordinateValue:hYStop andCoordinateType:YCoordType]) {
        coordinatesFormatOK = FALSE;
    }
    
    if (!coordinatesFormatOK)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: @"The coordinates of the street could not be found on the map!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        scaleValueAccordingToAreaHeight = 0.1;
        scaleValueAccordingToAreaWidth = 0.1;
        return CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    }
    
    NSString *refXCoord = [self compareCoordinateStart:wXStart andCoordinateStop:wXStop usingCoordinateType:XCoordType];
    NSString *refYCoord = [self compareCoordinateStart:hYStart andCoordinateStop:hYStop usingCoordinateType:YCoordType];
        
    NSDecimalNumber *XCoordDifference = [self returnAreaDimensionOfBlocksDimensionsForStartValue:wXStart andCoordinateStop:wXStop usingCoordinateType:XCoordType];
    NSDecimalNumber *YCoordDifference = [self returnAreaDimensionOfBlocksDimensionsForStartValue:hYStart andCoordinateStop:hYStop usingCoordinateType:YCoordType];
    
    scaleValueAccordingToAreaWidth = [self getNewValueForZoom:XCoordDifference ofType:XCoordType];
    scaleValueAccordingToAreaHeight = [self getNewValueForZoom:YCoordDifference ofType:YCoordType];
    
    int numberOfBlocksTillXPointReference = [elementsOfWidth indexOfObject:refXCoord];
    NSDecimalNumber *decNumberOfBlocksTillXPointReference = [[NSDecimalNumber alloc] initWithInt:numberOfBlocksTillXPointReference];
    NSDecimalNumber *distanceXAxisFromStartTillReference = [decHeightOfBlock decimalNumberByMultiplyingBy:decNumberOfBlocksTillXPointReference];
    
    int numberOfBlocksTillYPointReference = [elementsOfHeight indexOfObject:refYCoord];
    NSDecimalNumber *decNumberOfBlocksTillYPointReference = [[NSDecimalNumber alloc] initWithInt:numberOfBlocksTillYPointReference];
    NSDecimalNumber *distanceYAxisFromStartTillReference = [decWidthOfBlock decimalNumberByMultiplyingBy:decNumberOfBlocksTillYPointReference];
    
    NSDecimalNumber *decXMidCoordinate = [[NSDecimalNumber alloc] initWithFloat: CGRectGetMidX(self.scrollView.bounds)];
    NSDecimalNumber *decYMidCoordinate = [[NSDecimalNumber alloc] initWithFloat: CGRectGetMidY(self.scrollView.bounds)];
    
    NSDecimalNumber *decHalfOfImageWidth = [[NSDecimalNumber alloc] initWithFloat:widthOfImage/2];
    NSDecimalNumber *decHalfOfImageHeight = [[NSDecimalNumber alloc] initWithFloat:heightOfImage/2];
    
    NSDecimalNumber *decXCoordinateFinal = [[[decXMidCoordinate decimalNumberByAdding:decHalfOfImageWidth] decimalNumberBySubtracting:distanceXAxisFromStartTillReference] decimalNumberBySubtracting:[XCoordDifference decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:2]]];
    
    NSDecimalNumber *decYCoordinateFinal = [[[decYMidCoordinate decimalNumberByAdding:decHalfOfImageHeight] decimalNumberBySubtracting:distanceYAxisFromStartTillReference] decimalNumberBySubtracting:[YCoordDifference decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:2]]];

    CGPoint centerPoint = CGPointMake([decXCoordinateFinal floatValue], [decYCoordinateFinal floatValue]);
    
    //NSLog(@"Ref coordinate of X axis: %@",refXCoord);
    //NSLog(@"Ref coordinate of Y axis: %@",refYCoord);
    
    return centerPoint;
}

- (int)getLengthOfLetterCoordinateFrom:(NSString *)XandYCoordinate
{
    //this method returns the index of the first digit from the XandYCoordinate coordinate string
    for (int indexInString = 0; indexInString < [XandYCoordinate length]; indexInString++) {
        unichar individualCharacter = [XandYCoordinate characterAtIndex:indexInString];
        NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
        if ([numericSet characterIsMember:individualCharacter]) {
            return indexInString;
        }
    }
    return 0;
}

- (BOOL)checkCoordinateAccordingToTheGridUsingCoordinateValue:(NSString *)coordValue andCoordinateType:(int)typeOfCoordinate
{
    
    switch (typeOfCoordinate) {
        case 1: //XCoordType
            if ([elementsOfWidth indexOfObject:coordValue] >= [elementsOfWidth count]) {
                return FALSE;
            }
            return TRUE;
            break;
        case 2: //YCoordType
            if ([elementsOfHeight indexOfObject:coordValue] >= [elementsOfHeight count]) {
                return FALSE;
            }
            return TRUE;
            break;
        default:
            break;
    }
    return FALSE;
}

- (NSString *)compareCoordinateStart:(NSString *)startValue andCoordinateStop:(NSString *)stopValue usingCoordinateType:(int)typeOfCoordinate
{
    NSString *refCoordinate = startValue;
    
    switch (typeOfCoordinate) {
        case 1: //XCoordType
            if ([elementsOfWidth indexOfObject:stopValue] < [elementsOfWidth indexOfObject:startValue]) {
                refCoordinate = stopValue;
            }
            return refCoordinate;
            break;
        case 2: //YCoordType
            if ([elementsOfHeight indexOfObject:stopValue] < [elementsOfHeight indexOfObject:startValue]) {
                refCoordinate = stopValue;
            }
            
            return refCoordinate;
            break;
        default:
            break;
    }
    return nil;
}

- (NSDecimalNumber *)returnAreaDimensionOfBlocksDimensionsForStartValue:(NSString *)startValue andCoordinateStop:(NSString *)stopValue usingCoordinateType:(int)typeOfCoordinate
{
    switch (typeOfCoordinate) {
        case 1:
        {
            int numberOfXBlocks = abs([elementsOfWidth indexOfObject:stopValue] - [elementsOfWidth indexOfObject:startValue]) + 1;
            NSDecimalNumber *decNumberOfXBlocks = [[NSDecimalNumber alloc] initWithInt:numberOfXBlocks];
            return [decWidthOfBlock decimalNumberByMultiplyingBy:decNumberOfXBlocks];
        }
            break;
        case 2:
        {
            int numberOfYBlocks = abs([elementsOfHeight indexOfObject:stopValue] - [elementsOfHeight indexOfObject:startValue]) + 1;
            NSDecimalNumber *decNumberOfYBlocks = [[NSDecimalNumber alloc] initWithInt:numberOfYBlocks];
            return [decHeightOfBlock decimalNumberByMultiplyingBy:decNumberOfYBlocks];
        }
            break;
        default:
            break;
    }
    return [[NSDecimalNumber alloc] initWithInt:0];
}

- (float)getNewValueForZoom:(NSDecimalNumber *)dimension ofType:(int)typeOfCoordinate
{
    switch (typeOfCoordinate) {
        case 1:
        {
            if ([decWidthOfTheScrollView compare:dimension] == NSOrderedAscending)
            {
                float newValueForScale = [self calculateNewValueForScaleUsingStandardValue:decWidthOfTheScrollView andUsingNewValue:dimension];
                return newValueForScale;
            }
        }
            break;
        case 2:
        {
            if ([decHeightOfTheSCrollView compare:dimension] == NSOrderedAscending)
            {
                float newValueForScale = [self calculateNewValueForScaleUsingStandardValue:decWidthOfTheScrollView andUsingNewValue:dimension];
                return newValueForScale;
            }
            
        }
            break;
        default:
            break;
    }
    return 1.0f;
}

- (float)calculateNewValueForScaleUsingStandardValue:(NSDecimalNumber *)normalScaleValue andUsingNewValue:(NSDecimalNumber *)newScaleValue
{
    
    NSDecimalNumber *decNewScale = [normalScaleValue decimalNumberByDividingBy:newScaleValue];
    float newScale = [decNewScale floatValue];
    float diffToSubtract = newScale /10.f;
    newScale = newScale - diffToSubtract;
    return newScale;
}

- (CGPoint)retrieveCenterPointUsingView:(UIView *)view andCurrentOffset:(CGPoint)currentOffset
{
    
    CGFloat centerX = currentOffset.x;
    CGFloat centerY = currentOffset.y;
    if (view.frame.origin.x == 0) {
        centerX = -centerX + view.frame.size.width / 2.0;
    }
    if (view.frame.origin.y == 0) {
        centerY = -centerY + view.frame.size.height / 2.0;
    }
    return CGPointMake(centerX, centerY);
}

- (CGPoint)convertCenterPointToLocationRegardinTheLefUpperCorner:(CGPoint) centerPoint orientationPortrait:(BOOL)isOrientationPortrait
{
    CGFloat XMidCoordinate = screenRect.size.width/2;
    CGFloat YMidCoordinate = (screenRect.size.height-20)/2;
    
    if (isOrientationPortrait) {
        XMidCoordinate = screenRect.size.height/2;;
        YMidCoordinate = (screenRect.size.width-20)/2;
    }
    
    CGFloat XForRelativeLocation = XMidCoordinate + widthOfImage/2 - centerPoint.x;
    CGFloat YForRelativeLocation = YMidCoordinate + heightOfImage/2 - centerPoint.y;
    
    return CGPointMake(XForRelativeLocation, YForRelativeLocation);
}

- (CGPoint)getNewCenterPointUsingRelativePoint:(CGPoint)relativePoint
{
    CGFloat newCenterX = CGRectGetMidX(self.scrollView.bounds) + widthOfImage/2 - relativePoint.x;
    CGFloat newCenterY = CGRectGetMidY(self.scrollView.bounds) + heightOfImage/2 - relativePoint.y;
    return CGPointMake(newCenterX, newCenterY);
}

- (void)view:(UIView *)view setCenter:(CGPoint)centerPoint
{
    CGRect localViewFrame = view.frame;
    CGPoint contentOffSetScrollView = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - localViewFrame.size.width / 2.0;
    CGFloat y = centerPoint.y - localViewFrame.size.height / 2.0;
    
    if(x < 0)
    {
        contentOffSetScrollView.x = -x;
        localViewFrame.origin.x = 0.0;
    }
    else
    {
        localViewFrame.origin.x = x;
    }
    if(y < 0)
    {
        contentOffSetScrollView.y = -y;
        localViewFrame.origin.y = 0.0;
    }
    else
    {
        localViewFrame.origin.y = y;
    }
    
    view.frame = localViewFrame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    //SET NEW CENTER (CONTENTEN OFFSET FOR SCROLL VIEW)
    self.scrollView.contentOffset = contentOffSetScrollView;
    [UIView commitAnimations];
}

// MARK: - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{    
    return  self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"New value for offset: (%f,%f)",scrollView.contentOffset.x,scrollView.contentOffset.y);
}

- (NSString *)getSubstringFromActualSring:(NSString *)theActualString usingStartPoint:(int)theBegining andTheLength:(int)theLength
{
    NSRange rangeToGetFromString = NSMakeRange(theBegining, theLength);
    @try
    {
        NSString *theStringToReturn = [theActualString substringWithRange:rangeToGetFromString];
        return theStringToReturn;
    }
    @catch (NSException *exception)
    {
        return @"";
    }
}

- (IBAction)dismissTheViewAction:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.imageView setAlpha:0];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
