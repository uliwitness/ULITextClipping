//
//  ViewController.m
//  ULITextClipping
//
//  Created by Uli Kusterer on 04.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ViewController.h"
#import "NSString+ULIClippingFile.h"


@implementation ViewController

-(IBAction) chooseFile: (id)sender
{
	NSOpenPanel * filePicker = [NSOpenPanel openPanel];
	[filePicker beginSheetModalForWindow: self.view.window completionHandler: ^(NSInteger result)
	{
		if( result == NSFileHandlingPanelOKButton )
		{
			[self.pathControl setURL: filePicker.URL];
			[self updateTextView: self];
		}
	}];
}


-(IBAction) updateTextView: (id)sender
{
	NSAttributedString * attrStr = [NSAttributedString attributedStringWithContentsOfClippingFileURL: self.pathControl.URL];
	if( !attrStr )
		attrStr = [[NSAttributedString alloc] initWithString: @"" attributes: @{}];
	[self.textView.textStorage setAttributedString: attrStr];
}

@end
