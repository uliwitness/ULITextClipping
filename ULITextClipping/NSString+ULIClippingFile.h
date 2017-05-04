//
//  NSString+ULIClippingFile.h
//  ULITextClipping
//
//  Created by Uli Kusterer on 05.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface NSString (ULIClippingFile)

+(NSString*) stringWithContentsOfClippingFileURL: (NSURL*)inClippingURL;

@end

@interface NSAttributedString (ULIClippingFile)

+(NSAttributedString*) attributedStringWithContentsOfClippingFileURL: (NSURL*)inClippingURL;

@end


extern NSDictionary * ULIClippingDictionaryFromFileURL( NSURL * inClippingURL );
