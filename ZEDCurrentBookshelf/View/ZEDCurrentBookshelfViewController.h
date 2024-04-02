//
//  ZEDCurrentZEDBookshelfViewController.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <GAITrackedViewController.h>

#import "ZEDCurrentBookshelfViewInput.h"

@protocol ZEDCurrentBookshelfViewOutput;

@interface ZEDCurrentBookshelfViewController : GAITrackedViewController <ZEDCurrentBookshelfViewInput>

@property (nonatomic, strong) id<ZEDCurrentBookshelfViewOutput> output;

@end
