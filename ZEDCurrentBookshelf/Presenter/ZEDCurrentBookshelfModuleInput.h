//
//  ZEDCurrentBookshelfModuleInput.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ViperMcFlurry/ViperMcFlurry.h>

@class ZEDBookshelf;

@protocol ZEDCurrentBookshelfModuleInput <RamblerViperModuleInput>

- (void)configureModuleWithBookshelf:(ZEDBookshelf *)bookshelf;

@end
