//
//  SearchTableCell.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchTableCell.h"
#import "SearchItem.h"
#import "TMAvatarImageView.h"

@interface SearchTableCell()
@property (nonatomic, strong) TMNameTextField *titleTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) TMTextField *dateTextField;
- (SearchItem *)rowItem;
@end

@implementation SearchTableCell

- (SearchItem *)rowItem {
    return (SearchItem *)[super rowItem];
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        self.wantsLayer = YES;
        
    self.titleTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(66, 33, 200, 20)];
        [self.titleTextField setBordered:NO];
        [self.titleTextField setEditable:NO];
        [self.titleTextField setSelectable:NO];
        [self.titleTextField setAutoresizingMask:NSViewWidthSizable];
        [[self.titleTextField cell] setTruncatesLastVisibleLine:YES];
        [[self.titleTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        [self.titleTextField setDrawsBackground:NO];
//        [self.titleTextField setBackgroundColor:[NSColor redColor]];

        [self addSubview:self.titleTextField];
        
        self.statusTextField = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(66, 14, 200, 20)];
        [self.statusTextField setEditable:NO];
        [self.statusTextField setBordered:NO];
        [self.statusTextField setDrawsBackground:NO];
        [self.statusTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        [self.statusTextField setSelector:@selector(statusForSearchTableView)];
        [self.statusTextField setAutoresizingMask:NSViewWidthSizable];
        [[self.statusTextField cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.statusTextField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:self.statusTextField];

        
        self.dateTextField = [[TMTextField alloc] init];
        [self.dateTextField setEditable:NO];
        [self.dateTextField setBordered:NO];
        [self.dateTextField setAutoresizingMask:NSViewMinXMargin];
        [self.dateTextField setBackgroundColor:[NSColor clearColor]];
        [self.dateTextField setFont:[NSFont fontWithName:@"Helvetica-Light" size:11]];
        [self addSubview:self.dateTextField];
        
        self.avatarImageView = [TMAvatarImageView standartTableAvatar];
        [self addSubview:self.avatarImageView];

    }
    return self;
}

- (void) changeSelected:(BOOL)isSelected {
//    if(isSelected) {
//        [self setBorder:TMViewBorderTop | TMViewBorderBottom];
//    } else {
//        [self setBorder:0];
//    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    [DialogsViewController showPopupMenuForDialog:[self rowItem].dialog withEvent:theEvent forView:self];
}

- (void) checkSelected:(BOOL)isSelected {
    [self.titleTextField setSelected:isSelected];
    [self.statusTextField setSelected:isSelected];
    [[self rowItem].date setSelected:isSelected];
}

- (void)redrawRow {
    [super redrawRow];
    
    SearchItem *item = [self rowItem];
    
    
    if(item.dialog.type == DialogTypeChat) {
         [self.titleTextField setChat:item.chat];
    }
    
    if(item.dialog.type == DialogTypeUser) {
         [self.titleTextField setUser:item.user];
    }
    
    if(item.dialog.type == DialogTypeSecretChat) {
        [self.titleTextField setUser:item.user isEncrypted:YES];
    }
    
    if(item.dialog.type == DialogTypeBroadcast) {
        [self.titleTextField setBroadcast:item.dialog.broadcast];
    }
    
    
    
    
    [self.titleTextField sizeToFit];
    
    
    if(item.type != SearchItemMessage) {
        
        if(item.chat) {
            [self.avatarImageView setChat:item.chat];
            [self.statusTextField setChat:item.chat];
        } else {
            [self.avatarImageView setUser:item.user];
            [self.statusTextField setUser:item.user];
        }
        
        [self.titleTextField setFrameSize:NSMakeSize(self.bounds.size.width - 75, self.titleTextField.bounds.size.height)];

        
        [self.dateTextField setHidden:YES];
    } else {
        
        if(item.dialog.type == DialogTypeChat) {
            [self.avatarImageView setChat:item.chat];
        }
        
        if(item.dialog.type == DialogTypeUser || item.dialog.type == DialogTypeSecretChat) {
            [self.avatarImageView setUser:item.user];
        }
        
        if(item.dialog.type == DialogTypeBroadcast) {
            [self.avatarImageView setBroadcast:item.dialog.broadcast];
        }
        

        
        [self.statusTextField setUser:nil];
        [self.statusTextField setChat:nil];
        [self.statusTextField setAttributedStringValue:item.status];
        
        [self.dateTextField setHidden:NO];
        self.dateTextField.attributedStringValue = item.date;
        if(item.dateSize.width == 0) {
            [self.dateTextField sizeToFit];
            item.dateSize = self.dateTextField.frame.size;
        }
        
        [self.dateTextField setFrameSize:item.dateSize];
        
        [self.titleTextField setFrameSize:NSMakeSize(self.bounds.size.width - item.dateSize.width - 75, self.titleTextField.bounds.size.height)];
        
        [self.dateTextField setFrameOrigin:NSMakePoint(self.bounds.size.width - item.dateSize.width - 10, 34)];
    }
    
}

- (void)setHover:(BOOL)hover redraw:(BOOL)redraw {
    [super setHover:hover redraw:redraw];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.statusTextField setFrameSize:NSMakeSize(NSWidth(self.bounds) - 110, NSHeight(self.statusTextField.frame))];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    
    if(self.isSelected) {
        [BLUE_COLOR_SELECT set];
        NSRectFill(self.bounds);
    } else if(self.isHover) {
      //  [NSColorFromRGB(0xfafafa) set];
      //  NSRectFill(NSMakeRect(0, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH, self.bounds.size.height));
    } else {
        [NSColorFromRGB(0xffffff) set];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH, self.bounds.size.height));
        
//        [NSColorFromRGB(0xcccccc) set];
//        
//        NSRectFill(NSMakeRect(66, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH - 66, 1));
    }
    
}

@end
