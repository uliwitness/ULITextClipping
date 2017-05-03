//
//  AppDelegate.m
//  ULITextClipping
//
//  Created by Uli Kusterer on 04.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "AppDelegate.h"
#import "ULIResourceFork.h"
#import "ULIResourceForkStream.h"

#import <CoreServices/CoreServices.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSError * err = nil;
	ULIInputStream * fileStream = [ULIInputStream inputStreamForResourceForkWithURL: [NSURL fileURLWithPath: @"/Users/uli/OldStyle.textClipping"]];
	ULIResourceFork * fork = [ULIResourceFork resourceForkFromStream: fileStream error: &err];
	NSMutableDictionary * syntheticClippingDict = [NSMutableDictionary dictionaryWithCapacity: fork.resourceTypes.count];
	NSMutableDictionary * syntheticOSTypesDict = [NSMutableDictionary dictionaryWithCapacity: fork.resourceTypes.count];
	NSMutableDictionary * syntheticUTIsDict = [NSMutableDictionary dictionary];
	[syntheticClippingDict setObject: syntheticOSTypesDict forKey: @"OSType-Data"];
	[syntheticClippingDict setObject: syntheticUTIsDict forKey: @"UTI-Data"];
	for( NSString * currTypeStr in fork.resourceTypes )
	{
		ULIResourceType * currType = fork.resourceTypes[currTypeStr];
		if( [currTypeStr isEqualToString: @"TEXT"] )
		{
			[syntheticUTIsDict setObject: currType.resources.firstObject.resourceData forKey: @"com.apple.traditional-mac-plain-text"];
		}
		else if( [currTypeStr isEqualToString: @"utf8"] )
		{
			NSString * plainText = [[NSString alloc] initWithData: currType.resources.firstObject.resourceData encoding: NSUTF8StringEncoding];
			[syntheticUTIsDict setObject: plainText forKey: @"public.utf8-plain-text"];
		}
		else if( [currTypeStr isEqualToString: @"RTF "] )
		{
			NSString * plainText = [[NSString alloc] initWithData: currType.resources.firstObject.resourceData encoding: NSUTF8StringEncoding];
			[syntheticUTIsDict setObject: plainText forKey: @"public.rtf"];
		}
		else if( [currTypeStr isEqualToString: @"ut16"] )
		{
			[syntheticUTIsDict setObject: currType.resources.firstObject.resourceData forKey: @"public.utf16-external-plain-text"];
		}
		else if( [currTypeStr isEqualToString: @"utxt"] )
		{
			[syntheticUTIsDict setObject: currType.resources.firstObject.resourceData forKey: @"public.utf16-plain-text"];
		}
		else
		{
			[syntheticOSTypesDict setObject: currType.resources.firstObject.resourceData forKey: currType.resources.firstObject.resourceType];
		}
	}
	NSLog(@"%@", syntheticClippingDict);
	
	NSDictionary * clippingDict = [NSMutableDictionary dictionaryWithContentsOfURL: [NSURL fileURLWithPath: @"/Users/uli/NewStyle.textClipping"]];
	NSLog(@"%@", clippingDict);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
