//
//  ZEDCurrentBookshelfInteractor.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfInteractorInput.h"

@protocol ZEDCurrentBookshelfInteractorOutput;

@interface ZEDCurrentBookshelfInteractor : NSObject <ZEDCurrentBookshelfInteractorInput>

@property (nonatomic, weak) id<ZEDCurrentBookshelfInteractorOutput> output;

@end
