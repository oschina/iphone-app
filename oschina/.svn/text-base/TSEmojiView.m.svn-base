//
//  TSEmojiView.m
//  TSEmojiView
//
//  Created by Shawn Ma on 7/24/12.
//  Copyright (c) 2012 Telenav Software, Inc. All rights reserved.
//

#import "TSEmojiView.h"

#define TSEMOJIVIEW_COLUMNS 9
#define TSEMOJIVIEW_SPACES  0.2
#define TSEMOJIVIEW_KEYTOP_WIDTH 70
#define TSEMOJIVIEW_KEYTOP_HEIGHT 88
#define TSKEYTOP_SIZE 24
#define TSEMOJI_SIZE 24

//==============================================================================
// TSEmojiViewLayer
//==============================================================================
@interface TSEmojiViewLayer : CALayer {
@private
    CGImageRef _keytopImage;;
}
@property (nonatomic, retain) UIImage* emoji;
@end

@implementation TSEmojiViewLayer
@synthesize emoji = _emoji;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    _keytopImage = nil;
    _emoji = nil;
}

- (void)drawInContext:(CGContextRef)context
{
    //从后台返回需要重新获取图片,Fixes Bug
//    _keytopImage = [[UIImage imageNamed:@"emoji_touch.png"] CGImage];
//    _keytopImage = [[UIImage imageNamed:@"emoji_touch@2x.png"] CGImage];
    
//    UIGraphicsBeginImageContext(CGSizeMake(TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT));
//    CGContextTranslateCTM(context, 0.0, TSEMOJIVIEW_KEYTOP_HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT), _keytopImage);
    UIGraphicsEndImageContext();
    
    //
    UIGraphicsBeginImageContext(CGSizeMake(TSKEYTOP_SIZE, TSKEYTOP_SIZE));
    CGContextDrawImage(context, CGRectMake((TSEMOJIVIEW_KEYTOP_WIDTH - TSKEYTOP_SIZE) / 2 , 45, TSKEYTOP_SIZE, TSKEYTOP_SIZE), [_emoji CGImage]);
    UIGraphicsEndImageContext();
}

@end

//==============================================================================
// TSEmojiView
//==============================================================================
@interface TSEmojiView() {
    NSMutableArray *_emojiArray;
    NSMutableArray *_symbolArray;
    
    NSInteger _touchedIndex;
    
    UIImage *rectBg;
}
@end

@implementation TSEmojiView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _emojiArray = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"001.png"],
                       [UIImage imageNamed:@"002.png"],
                       [UIImage imageNamed:@"003.png"],
                       [UIImage imageNamed:@"004.png"],
                       [UIImage imageNamed:@"005.png"],
                       [UIImage imageNamed:@"006.png"],
                       [UIImage imageNamed:@"007.png"],
                       [UIImage imageNamed:@"008.png"],
                       [UIImage imageNamed:@"009.png"],
                       [UIImage imageNamed:@"010.png"],
                       [UIImage imageNamed:@"011.png"],
                       [UIImage imageNamed:@"012.png"],
                       [UIImage imageNamed:@"013.png"],
                       [UIImage imageNamed:@"014.png"],
                       [UIImage imageNamed:@"015.png"],
                       [UIImage imageNamed:@"016.png"],
                       [UIImage imageNamed:@"017.png"],
                       [UIImage imageNamed:@"018.png"],
                       [UIImage imageNamed:@"019.png"],
                       [UIImage imageNamed:@"020.png"],
                       [UIImage imageNamed:@"021.png"],
                       [UIImage imageNamed:@"022.png"],
                       [UIImage imageNamed:@"023.png"],
                       [UIImage imageNamed:@"024.png"],
                       [UIImage imageNamed:@"025.png"],
                       [UIImage imageNamed:@"026.png"],
                       [UIImage imageNamed:@"027.png"],
                       [UIImage imageNamed:@"028.png"],
                       
                       [UIImage imageNamed:@"029.png"],
                       [UIImage imageNamed:@"030.png"],
                       [UIImage imageNamed:@"031.png"],
                       [UIImage imageNamed:@"032.png"],
                       [UIImage imageNamed:@"033.png"],
                       [UIImage imageNamed:@"034.png"],
                       [UIImage imageNamed:@"035.png"],
                       [UIImage imageNamed:@"036.png"],
                       [UIImage imageNamed:@"037.png"],
                       [UIImage imageNamed:@"038.png"],
                       [UIImage imageNamed:@"039.png"],
                       [UIImage imageNamed:@"040.png"],
                       [UIImage imageNamed:@"041.png"],
                       [UIImage imageNamed:@"042.png"],
                       [UIImage imageNamed:@"043.png"],
                       [UIImage imageNamed:@"044.png"],
                       [UIImage imageNamed:@"045.png"],
                       [UIImage imageNamed:@"046.png"],
                       [UIImage imageNamed:@"047.png"],
                       [UIImage imageNamed:@"048.png"],
                       [UIImage imageNamed:@"049.png"],
                       
                       [UIImage imageNamed:@"050.png"],
                       [UIImage imageNamed:@"051.png"],
                       [UIImage imageNamed:@"052.png"],
                       [UIImage imageNamed:@"053.png"],
                       [UIImage imageNamed:@"054.png"],
                       [UIImage imageNamed:@"055.png"],
                       [UIImage imageNamed:@"056.png"],
                       [UIImage imageNamed:@"057.png"],
                       [UIImage imageNamed:@"058.png"],
                       [UIImage imageNamed:@"059.png"],
                       
                       [UIImage imageNamed:@"060.png"],
                       [UIImage imageNamed:@"061.png"],
                       [UIImage imageNamed:@"062.png"],
                       [UIImage imageNamed:@"063.png"],
                       [UIImage imageNamed:@"064.png"],
                       [UIImage imageNamed:@"065.png"],
                       [UIImage imageNamed:@"067.png"],
                       [UIImage imageNamed:@"068.png"],
                       [UIImage imageNamed:@"069.png"],
                       
                       [UIImage imageNamed:@"070.png"],
                       [UIImage imageNamed:@"071.png"],
                       [UIImage imageNamed:@"072.png"],
                       [UIImage imageNamed:@"073.png"],
                       [UIImage imageNamed:@"074.png"],
                       [UIImage imageNamed:@"075.png"],
                       [UIImage imageNamed:@"076.png"],
                       [UIImage imageNamed:@"077.png"],
                       [UIImage imageNamed:@"078.png"],
                       [UIImage imageNamed:@"079.png"],
                       
                       [UIImage imageNamed:@"080.png"],
                       [UIImage imageNamed:@"081.png"],
                       [UIImage imageNamed:@"082.png"],
                       [UIImage imageNamed:@"083.png"],
                       [UIImage imageNamed:@"084.png"],
                       [UIImage imageNamed:@"085.png"],
                       [UIImage imageNamed:@"086.png"],
                       [UIImage imageNamed:@"087.png"],
                       [UIImage imageNamed:@"088.png"],
                       [UIImage imageNamed:@"089.png"],
                       
                       [UIImage imageNamed:@"090.png"],
                       [UIImage imageNamed:@"091.png"],
                       [UIImage imageNamed:@"092.png"],
                       [UIImage imageNamed:@"093.png"],
                       [UIImage imageNamed:@"094.png"],
                       [UIImage imageNamed:@"095.png"],
                       [UIImage imageNamed:@"096.png"],
                       [UIImage imageNamed:@"097.png"],
                       [UIImage imageNamed:@"098.png"],
                       [UIImage imageNamed:@"099.png"],
                       
                       [UIImage imageNamed:@"100.png"],
                       [UIImage imageNamed:@"101.png"],
                       [UIImage imageNamed:@"103.png"],
                       [UIImage imageNamed:@"104.png"],
                       [UIImage imageNamed:@"105.png"],

                       nil];
        
        _symbolArray = [NSArray arrayWithObjects:
                        @"0", 
                        @"1", 
                        @"2",
                        @"3", 
                        @"4", 
                        @"5",
                        @"6", 
                        @"7", 
                        @"8",
                        @"9",
                        
                        @"10",
                        @"11",
                        @"12",
                        @"13",
                        @"14",
                        @"15",
                        @"16",
                        @"17",
                        @"18",
                        @"19",
                        
                        @"20",
                        @"21",
                        @"22",
                        @"23",
                        @"24",
                        @"25",
                        @"26",
                        @"27",
                        @"28",
                        @"29",
                        
                        @"30",
                        @"31",
                        @"32",
                        @"33",
                        @"34",
                        @"35",
                        @"36",
                        @"37",
                        @"38",
                        @"39",

                        @"40",
                        @"41",
                        @"42",
                        @"43",
                        @"44",
                        @"45",
                        @"46",
                        @"47",
                        @"48",
                        @"49",
                        
                        @"50",
                        @"51",
                        @"52",
                        @"53",
                        @"54",
                        @"55",
                        @"56",
                        @"57",
                        @"58",
                        @"59",
                        
                        @"60",
                        @"61",
                        @"62",
                        @"63",
                        @"64",
                        @"66",
                        @"67",
                        @"68",
                        @"69",
                        
                        @"70",
                        @"71",
                        @"72",
                        @"73",
                        @"74",
                        @"75",
                        @"76",
                        @"77",
                        @"78",
                        @"79",
                        
                        @"80",
                        @"81",
                        @"82",
                        @"83",
                        @"84",
                        @"85",
                        @"86",
                        @"87",
                        @"88",
                        @"89",
                        
                        @"90",
                        @"91",
                        @"92",
                        @"93",
                        @"94",
                        @"95",
                        @"96",
                        @"97",
                        @"98",
                        @"99",
                        
                        @"100",
                        @"102",
                        @"103",
                        @"104",
                        nil];
        
//        self.backgroundColor = [[UIColor alloc] initWithRed:239 green:245 blue:245 alpha:255];
        self.backgroundColor = [Tool getBackgroundColor];
        rectBg = [UIImage imageNamed:@"k.png"];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    _emojiArray = nil;
    _symbolArray = nil;
}

- (void)drawRect:(CGRect)rect
{
    int index =0;
    for(UIImage *image in _emojiArray) {
        float originX = (320 / TSEMOJIVIEW_COLUMNS) * (index % TSEMOJIVIEW_COLUMNS) + ((320 / TSEMOJIVIEW_COLUMNS) - TSEMOJI_SIZE ) / 2;
        float originY = (index / TSEMOJIVIEW_COLUMNS) * (320 / TSEMOJIVIEW_COLUMNS) + ((320 / TSEMOJIVIEW_COLUMNS) - TSEMOJI_SIZE ) / 2;
        
        
        [image drawInRect:CGRectMake(originX+6, originY+6, TSEMOJI_SIZE, TSEMOJI_SIZE)];
        [rectBg drawInRect:CGRectMake(originX, originY, 36, 36)];
        index++;
    }
}

#pragma mark -
#pragma mark Actions
- (NSUInteger)indexWithEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger x = [touch locationInView:self].x / (self.bounds.size.width / TSEMOJIVIEW_COLUMNS);
    NSUInteger y = [touch locationInView:self].y / (self.bounds.size.width / TSEMOJIVIEW_COLUMNS);
    
    return x + (y * TSEMOJIVIEW_COLUMNS);
}

- (void)updateWithIndex:(NSUInteger)index
{
    if(index < _emojiArray.count) {
        _touchedIndex = index;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if(index < _emojiArray.count) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self updateWithIndex:index];
        [CATransaction commit];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if (_touchedIndex >=0 && index != _touchedIndex && index < _emojiArray.count) {
        [self updateWithIndex:index];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && _touchedIndex >= 0) {
        if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)]) {
            [self.delegate didTouchEmojiView:self touchedEmoji:[_symbolArray objectAtIndex:_touchedIndex]];
        }
    }
    _touchedIndex = -1;
    [self setNeedsDisplay];
}

@end
