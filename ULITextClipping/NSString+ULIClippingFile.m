//
//  NSString+ULIClippingFile.m
//  ULITextClipping
//
//  Created by Uli Kusterer on 05.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "NSString+ULIClippingFile.h"
#import "ULIResourceFork.h"
#import "ULIResourceForkStream.h"
#import <CoreServices/CoreServices.h>


@implementation NSString (ULIClippingFile)

+(NSString*) stringWithContentsOfClippingFileURL: (NSURL*)inClippingURL
{
	NSDictionary * clippingDict = ULIClippingDictionaryFromFileURL( inClippingURL );
	NSString * clippingStr = clippingDict[@"public.utf8-plain-text"];
	return clippingStr;
}

@end

@implementation NSAttributedString (ULIClippingFile)

+(NSAttributedString*) attributedStringWithContentsOfClippingFileURL: (NSURL*)inClippingURL
{
	NSAttributedString * attrStr = nil;
	NSDictionary * clippingDict = ULIClippingDictionaryFromFileURL( inClippingURL );
	NSString * rtfString = clippingDict[@"UTI-Data"][@"public.rtf"];
	if( rtfString )
	{
		attrStr = [[NSAttributedString alloc] initWithRTF: [rtfString dataUsingEncoding: NSUTF8StringEncoding] documentAttributes: NULL];
	}
	if( !attrStr )
	{
		NSString * clippingStr = clippingDict[@"UTI-Data"][@"public.utf8-plain-text"];
		if( clippingStr )
			attrStr = [[NSAttributedString alloc] initWithString: clippingStr attributes: @{}];
	}
	return attrStr;
}

@end


NSDictionary * ULIClippingDictionaryFromFileURL( NSURL * inClippingURL )
{
	NSDictionary * clippingDict = [NSMutableDictionary dictionaryWithContentsOfURL: inClippingURL];
	if( !clippingDict )	// Not a new plist clipping? Try reading old resource-based format and convert to the same plist-style dictionary.
	{
		NSError * err = nil;
		ULIInputStream * fileStream = [ULIInputStream inputStreamForResourceForkWithURL: inClippingURL];
		ULIResourceFork * fork = [ULIResourceFork resourceForkFromStream: fileStream error: &err];
		
		NSMutableDictionary * syntheticClippingDict = [NSMutableDictionary dictionaryWithCapacity: fork.resourceTypes.count];
		NSMutableDictionary * syntheticOSTypesDict = [NSMutableDictionary dictionaryWithCapacity: fork.resourceTypes.count];
		NSMutableDictionary * syntheticUTIsDict = [NSMutableDictionary dictionary];
		[syntheticClippingDict setObject: syntheticOSTypesDict forKey: @"OSType-Data"];
		[syntheticClippingDict setObject: syntheticUTIsDict forKey: @"UTI-Data"];
		for( NSString * currTypeStr in fork.resourceTypes )
		{
			ULIResourceType * currType = fork.resourceTypes[currTypeStr];
			NSString * utiForType = CFBridgingRelease( UTTypeCreatePreferredIdentifierForTag( kUTTagClassOSType, (__bridge CFStringRef)currTypeStr, NULL ) );
			if( [currTypeStr isEqualToString: @"utf8"] )
			{
				NSString * plainText = [[NSString alloc] initWithData: currType.resources.firstObject.resourceData encoding: NSUTF8StringEncoding];
				[syntheticUTIsDict setObject: plainText forKey: @"public.utf8-plain-text"];
			}
			else if( [currTypeStr isEqualToString: @"RTF "] )
			{
				NSString * plainText = [[NSString alloc] initWithData: currType.resources.firstObject.resourceData encoding: NSUTF8StringEncoding];
				[syntheticUTIsDict setObject: plainText forKey: @"public.rtf"];
			}
			else if( utiForType != nil && !UTTypeIsDynamic((__bridge CFStringRef _Nonnull)utiForType) )	// Found a UTI? Move it into UTI-Data dict.
			{
				[syntheticUTIsDict setObject: currType.resources.firstObject.resourceData forKey: utiForType];
			}
			else	// Legacy type without UTI? Stick the data in the OSType-Data dict.
			{
				[syntheticOSTypesDict setObject: currType.resources.firstObject.resourceData forKey: currType.resources.firstObject.resourceType];
			}
		}
		clippingDict = syntheticClippingDict;
	}
	
	return clippingDict;
}
