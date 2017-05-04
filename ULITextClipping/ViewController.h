//
//  ViewController.h
//  ULITextClipping
//
//  Created by Uli Kusterer on 04.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property IBOutlet NSPathControl * pathControl;
@property IBOutlet NSTextView * textView;

-(IBAction) chooseFile: (id)sender;
-(IBAction) updateTextView: (id)sender;

@end

