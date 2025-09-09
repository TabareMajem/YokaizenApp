//
//  QCSportInfoModel.h
//  QCBandSDK
//
//  Created by steve on 2024/2/21.
//

#import <Foundation/Foundation.h>
#import "OdmSportPlusModels.h"
#import "QCDFU_Utils.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCSportInfoModel : NSObject

@property (nonatomic, assign) OdmSportPlusExerciseModelType sportType;
@property (nonatomic, assign) QCSportState state;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger hr;
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) NSInteger calorie;
@end

NS_ASSUME_NONNULL_END
/*
 NSMutableDictionary *resDic = [NSMutableDictionary new];
 NSInteger type = bytes[1];
 [resDic setValue:@(type) forKey:@"type"];
 
 NSInteger status = bytes[2];
 [resDic setValue:@(status) forKey:@"status"];
 
 Byte timeB[2] = {bytes[3],bytes[4]};
 NSInteger time = [OdmCmdHelper intFromByte:timeB Length:2];
 [resDic setValue:@(time) forKey:@"time"];
 
 
 NSInteger hr = bytes[5];
 [resDic setValue:@(hr) forKey:@"hr"];
 
 Byte stepB[3] = {bytes[6],bytes[7],bytes[8]};
 NSInteger step = [OdmCmdHelper intFromByte:stepB Length:3];
 [resDic setValue:@(step) forKey:@"step"];
 
 Byte distanceB[3] = {bytes[9],bytes[10],bytes[11]};
 NSInteger distance = [OdmCmdHelper intFromByte:distanceB Length:3];
 [resDic setValue:@(distance) forKey:@"distance"];
 
 Byte calB[3] = {bytes[12],bytes[13],bytes[14]};
 NSInteger cal= [OdmCmdHelper intFromByte:calB Length:3];
 [resDic setValue:@(cal) forKey:@"cal"];
 */
