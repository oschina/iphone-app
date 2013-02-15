
/*
 Copyright 2011 Ahmet Ardal
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

//
//  SSPhotoCropperViewController.m
//  SSPhotoCropperDemo
//
//  Created by Ahmet Ardal on 10/17/11.
//  Copyright 2011 SpinningSphere Labs. All rights reserved.
//

#import "SSPhotoCropperViewController.h"

@interface SSPhotoCropperViewController(Private)
- (void) loadPhoto;
- (void) setScrollViewBackground;
- (IBAction) saveAndClose:(id)sender;
- (IBAction) cancelAndClose:(id)sender;
- (BOOL) isRectanglePositionValid:(CGPoint)pos;
- (IBAction) imageMoved:(id)sender withEvent:(UIEvent *)event;
- (IBAction) imageTouch:(id)sender withEvent:(UIEvent *)event;
@end

@implementation SSPhotoCropperViewController

@synthesize scrollView, photo, imageView, cropRectangleButton, infoButton, delegate,
            minZoomScale, maxZoomScale, infoMessageTitle, infoMessageBody, photoCropperTitle;

- (id) initWithPhoto:(UIImage *)aPhoto
            delegate:(id<SSPhotoCropperDelegate>)aDelegate
{
    return [self initWithPhoto:aPhoto
                      delegate:aDelegate
                        uiMode:SSPCUIModePresentedAsModalViewController
               showsInfoButton:YES];
}

- (id) initWithPhoto:(UIImage *)aPhoto
            delegate:(id<SSPhotoCropperDelegate>)aDelegate
              uiMode:(SSPhotoCropperUIMode)uiMode
     showsInfoButton:(BOOL)showsInfoButton
{
    if (!(self = [super initWithNibName:@"SSPhotoCropperViewController" bundle:nil])) {
        return self;
    }

    self.photo = aPhoto;
    self.delegate = aDelegate;
    _uiMode = uiMode;
    _showsInfoButton = showsInfoButton;

    self.minZoomScale = 0.5f;
    self.maxZoomScale = 3.0f;

    self.infoMessageTitle = @"In order to crop the photo";
    self.infoMessageBody = @"Use two of your fingers to zoom in and out the photo and drag the"
                           @" green window to crop any part of the photo you would like to use.";
    self.photoCropperTitle = @"头像裁减";

    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.photo = nil;
        self.delegate = nil;
    }
    return self;
}

- (void) dealloc
{
    [self.scrollView release];
    [self.photo release];
    [self.imageView release];
    [self.cropRectangleButton release];
    [self.infoButton release];
    [self.infoMessageTitle release];
    [self.infoMessageBody release];
    [self.photoCropperTitle release];
    [super dealloc];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction) infoButtonTapped:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:self.infoMessageTitle
                                                 message:self.infoMessageBody
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    [av release];
}


#pragma -
#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    //
    // setup view ui
    //
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(saveAndClose:)];
    self.navigationItem.rightBarButtonItem = bi;
    [bi release];

    if (_uiMode == SSPCUIModePresentedAsModalViewController) {
        bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                           target:self
                                                           action:@selector(cancelAndClose:)];
        self.navigationItem.leftBarButtonItem = bi;
        [bi release];
    }

    if (!_showsInfoButton) {
        [self.infoButton setHidden:YES];
    }

    self.title = self.photoCropperTitle;

    //
    // photo cropper ui stuff
    //
    [self setScrollViewBackground];
    [self.scrollView setMinimumZoomScale:self.minZoomScale];
    [self.scrollView setMaximumZoomScale:self.maxZoomScale];

    [self.cropRectangleButton addTarget:self
                                 action:@selector(imageTouch:withEvent:)
                       forControlEvents:UIControlEventTouchDown];
    [self.cropRectangleButton addTarget:self
                                 action:@selector(imageMoved:withEvent:)
                       forControlEvents:UIControlEventTouchDragInside];

    if (self.photo != nil) {
        [self loadPhoto];
    }
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma -
#pragma UIScrollViewDelegate Methods

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


#pragma -
#pragma Private Methods

- (void) loadPhoto
{
    if (self.photo == nil) {
        return;
    }

    CGFloat w = self.photo.size.width;
    CGFloat h = self.photo.size.height;
    CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, roundf(w / 2.0f), roundf(h / 2.0f));
    self.scrollView.contentSize = imageViewFrame.size;

    UIImageView *iv = [[UIImageView alloc] initWithFrame:imageViewFrame];
    iv.image = self.photo;
    [self.scrollView addSubview:iv];
    self.imageView = iv;
    [iv release];
}

- (void) setScrollViewBackground
{
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo_cropper_bg"]];
}

- (UIImage *) croppedPhoto
{
    CGFloat ox = self.scrollView.contentOffset.x;
    CGFloat oy = self.scrollView.contentOffset.y;
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat cx = (ox + self.cropRectangleButton.frame.origin.x + 15.0f) * 2.0f / zoomScale;
    CGFloat cy = (oy + self.cropRectangleButton.frame.origin.y + 15.0f) * 2.0f / zoomScale;
    CGFloat cw = 300.0f / zoomScale;
    CGFloat ch = 300.0f / zoomScale;
    CGRect cropRect = CGRectMake(cx, cy, cw, ch);
    
    NSLog(@"---------- cropRect: %@", NSStringFromCGRect(cropRect));
    NSLog(@"--- self.photo.size: %@", NSStringFromCGSize(self.photo.size));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.photo CGImage], cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSLog(@"------- result.size: %@", NSStringFromCGSize(result.size));
    
    return result;
}

- (IBAction) saveAndClose:(id)sender
{
    NSLog(@"----------- zoomScale: %.04f", self.scrollView.zoomScale);
    NSLog(@"------- contentOffset: %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    NSLog(@"-- contentScaleFactor: %.04f", self.scrollView.contentScaleFactor);
    NSLog(@"--------- contentSize: %@", NSStringFromCGSize(self.scrollView.contentSize));

    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropper:didCropPhoto:)]) {
        [self.delegate photoCropper:self didCropPhoto:[self croppedPhoto]];
    }
}

- (IBAction) cancelAndClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropperDidCancel:)]) {
        [self.delegate photoCropperDidCancel:self];
    }
}

- (BOOL) isRectanglePositionValid:(CGPoint)pos
{
    CGRect innerRect = CGRectMake((pos.x + 15), (pos.y + 15), 150, 150);
    return CGRectContainsRect(self.scrollView.frame, innerRect);
}

- (IBAction) imageMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];

    CGPoint prev = _lastTouchDownPoint;
    _lastTouchDownPoint = point;
    CGFloat diffX = point.x - prev.x;
    CGFloat diffY = point.y - prev.y;

    UIControl *button = sender;
    CGRect newFrame = button.frame;
    newFrame.origin.x += diffX;
    newFrame.origin.y += diffY;
    if ([self isRectanglePositionValid:newFrame.origin]) {
        button.frame = newFrame;
    }
}

- (IBAction) imageTouch:(id)sender withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    _lastTouchDownPoint = point;
    NSLog(@"imageTouch. point: %@", NSStringFromCGPoint(point));
}

@end
