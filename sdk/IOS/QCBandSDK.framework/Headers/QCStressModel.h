//
//  QCStressModel.h
//  QCBandSDK
//
//  Created by steve on 2024/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCStressModel : NSObject

@property (nonatomic, strong) NSString *date;                  // Date, formart:"yyyy-MM-dd"
@property (nonatomic, strong) NSArray<NSNumber *> *stresses; // stress array
@property (nonatomic, assign) NSInteger secondInterval;        // data interval,unit:s

@end

NS_ASSUME_NONNULL_END
