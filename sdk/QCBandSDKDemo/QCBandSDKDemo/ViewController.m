//
//  ViewController.m
//  QCBandSDKDemo
//
//  Created by steve on 2021/7/3.
//

#import "ViewController.h"
#import "QCCentralManager.h"
#import <QCBandSDK/QCSDKManager.h>
#import <QCBandSDK/QCSDKCmdCreator.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CollectionViewFeatureCell.h"
#import <QCBandSDK/QCSleepModel.h>
#import <QCBandSDK/QCSportModel.h>
#import <QCBandSDK/OdmSportPlusModels.h>
#import <QCBandSDK/QCManualHeartRateModel.h>
#import "QCScanViewController.h"
#import <QCBandSDK/QCManualHeartRateModel.h>
#import <QCBandSDK/QCDimingTimeInfo.h>

typedef NS_ENUM(NSInteger, QCFeatureType) {
    QCFeatureTypeAlertBinding = 0,              //Bind Notification(绑定通知)
    QCFeatureTypeSetTime,                       //Set Watch Time(设置手表时间)
    QCFeatureTypeSetMyProfile,                  //Set personal information(设置个人信息)
    QCFeatureTypeGetFirmware,                   //Get firmware information(获取固件信息)
    QCFeatureTypeGetPower,                      //Get battery information(获取电量信息)
    QCFeatureTypeSleepByDay,                    //get a day of sleep(获取某一天睡眠)
    QCFeatureTypeSleepFromDay,                  //Get day-to-day sleep(获取某一天到今天睡眠)
    QCFeatureTypeTakePicture,                   //Take Picture(拍照)
    QCFeatureTypeDFUUpdate,                     //Firmware upgrade(固件升级)
    QCFeatureTypeGetSteps,                      //Get pedometer data(获取计步数据)
    QCFeatureTypeHRMeasuring,                   //Heart rate measurement(心率测量)
    QCFeatureTypeGetSportRecords,
    QCFeatureTypeRealTimeHeartRateStart,             //RealTime HeartRate(实时心率)
    QCFeatureTypeCount,
};

static NSString *const kQCLastConnectedIdentifier = @"kQCLastConnectedIdentifier";
static NSInteger const kQCHoldRealTimeHeartRateTimeout = 20;

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,QCCentralManagerDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UICollectionView *featureList;

/*中心角色,app*/
@property (strong, nonatomic) CBCentralManager *centerManager;

@property (nonatomic,strong)UIBarButtonItem *rightItem;

@property (nonatomic,strong)NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Feature";
    
    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                      style:(UIBarButtonItemStylePlain)
                                                     target:self
                                                     action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = self.rightItem;
        
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.minimumLineSpacing = 20;
    _flowLayout.minimumInteritemSpacing = 10;
    _flowLayout.itemSize = CGSizeMake(100, 40);
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _featureList = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) collectionViewLayout:_flowLayout];
    _featureList.backgroundColor = [UIColor clearColor];
    _featureList.delegate = self;
    _featureList.dataSource = self;
    _featureList.scrollEnabled = YES;
    _featureList.contentInset = UIEdgeInsetsMake(44, 20, 10, 20);
    [_featureList registerClass:[CollectionViewFeatureCell class] forCellWithReuseIdentifier:NSStringFromClass([CollectionViewFeatureCell class])];
    [self.view addSubview:_featureList];
    
    //Set Scan and Connect delegate
    [QCCentralManager shared].delegate = self;
    
    //[QCSDKManager shareInstance].debug = YES;
    
    [QCSDKManager shareInstance].findPhone = ^(NSInteger status){
        if (status == 1) {
            NSLog(@"Start finding phone");
        }
        else if (status == 2) {
            NSLog(@"Stop looking for phone");
        }
    };
    
    [QCSDKManager shareInstance].switchToPicture = ^{
        NSLog(@"Enter the photo page");
    };
    
    [QCSDKManager shareInstance].takePicture = ^{
        NSLog(@"Click on the watch to take a photo");
    };
    
    [QCSDKManager shareInstance].stopTakePicture = ^{
        NSLog(@"The watch ends taking pictures");
    };
    
    [QCSDKManager shareInstance].realTimeHeartRate = ^(NSInteger hr){
        NSLog(@"The RealTime HeartRate is :%zd",hr);
    };
    
    //Supported by some Rings
    [QCSDKManager shareInstance].currentStepInfo = ^(NSInteger step, NSInteger calorie, NSInteger distance) {
        NSLog(@"step:%zd,calorie(unit:calorie):%zd,distance(unit:meter):%zd",step,calorie,distance);
    };
    
    //Supported by Ring
    //App send start sport cmd
    [QCSDKManager shareInstance].currentSportInfo = ^(QCSportInfoModel * _Nonnull sportInfo) {
        NSLog(@"sportType:%zd,duration:%zd,state:%u,hr:%zd,step:%zd,calorie(unit:calorie):%zd,distance(unit:meter):%zd",sportInfo.sportType,sportInfo.duration,sportInfo.state,sportInfo.hr,sportInfo.step,sportInfo.calorie,sportInfo.distance);
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [QCCentralManager shared].delegate = self;
    [self didState:[QCCentralManager shared].deviceState];
}

- (void)rightAction {
 
    if([self.rightItem.title isEqualToString:@"Unbind"]) {
        [[QCCentralManager shared] remove];
    }
    else if ([self.rightItem.title isEqualToString:@"Search"])  {
        QCScanViewController *viewCtrl = [[QCScanViewController alloc] init];
        [self.navigationController pushViewController:viewCtrl animated:true];
    }
}

#pragma mark - QCCentralManagerDelegate
- (void)didState:(QCState)state {
    self.title = @"Feature";
    switch(state) {
        case QCStateUnbind:
            self.rightItem.title = @"Search";
            self.featureList.hidden = YES;
            break;
        case QCStateConnecting:
            self.title = [QCCentralManager shared].connectedPeripheral.name;
            self.rightItem.title = @"Connecting";
            self.rightItem.enabled = NO;
            self.featureList.hidden = YES;
            break;
        case QCStateConnected:
            self.title = [QCCentralManager shared].connectedPeripheral.name;
            self.rightItem.title = @"Unbind";
            self.rightItem.enabled = YES;
            self.featureList.hidden = NO;
            
            
            //Set Smartwatch time get feature states
            [self setTime];
            break;
        case QCStateUnkown:
            break;
        case QCStateDisconnecting:
        case QCStateDisconnected:
            self.rightItem.title = @"Search";
            self.rightItem.enabled = YES;
            self.featureList.hidden = YES;
            break;
    }
}

- (void)didBluetoothState:(QCBluetoothState)state {
    
}

- (void)didConnected:(CBPeripheral *)peripheral     //用户可以返回设备类型
{
    NSLog(@"didConnected");
    self.rightItem.enabled = YES;
    self.title = peripheral.name;
}

- (void)didDisconnecte:(CBPeripheral *)peripheral {
    NSLog(@"didDisconnecte");
    self.title = @"Feature";
    
    self.rightItem.title = @"Search";
    self.rightItem.enabled = YES;
    self.featureList.hidden = YES;
}

- (void)didFailConnected:(CBPeripheral *)peripheral {
    
    NSLog(@"didFailConnected");
    self.rightItem.enabled = YES;
}

#pragma mark - Feature Action
- (void)setTime {
    NSLog(@"set time");
    [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary * _Nonnull info) {
        
        NSLog(@"Max Dials:%@",[info objectForKey:QCBandFeatureMaxDial]);
        
        NSLog(@"Set time successfully:%@",info);
    } failed:^{
        NSLog(@"Failed to set time");
    }];
}
- (void)setAlertBinding {
    NSLog(@"set binding vibration");
    [QCSDKCmdCreator alertBindingSuccess:^{
        NSLog(@"Set the binding vibration successfully");
    } fail:^{
        NSLog(@"Failed to set binding vibration");
    }];
}

- (void)setMyProfile {
    NSLog(@"Set personal information");
    [QCSDKCmdCreator setTimeFormatTwentyfourHourFormat:YES      //: YES 24 hour system; NO 12 hour system
                                          metricSystem:YES      //: YES metric system; NO British system
                                                gender:0        //(0=Male，1=Female)
                                                   age:18
                                                height:180      //cm
                                                weight:130      //kg
                                               sbpBase:105      //(reserved value, default 0)
                                               dbpBase:75       //(reserved value, default 0)
                                          hrAlarmValue:160      //(reserved value, default 0)
                                               success:^(BOOL twentyfourHourFormat, BOOL metricSystem, NSInteger gender, NSInteger age, NSInteger height, NSInteger weight, NSInteger sbpBase, NSInteger dbpBase, NSInteger hrAlarmValue)
    {
        NSLog(@"Set personal information successfully");
        
        [QCSDKCmdCreator getTimeFormatInfo:^(BOOL isTwentyfour, BOOL isMetricSystem, NSInteger gender, NSInteger age, NSInteger height, NSInteger weight, NSInteger sbpBase, NSInteger dbpBase, NSInteger hrAlarmValue) {
            NSLog(@"isTwentyfour:%d, isMetricSystem:%d",isTwentyfour,isMetricSystem);
        } fail:^{
            
        }];
        
        
    } fail:^{
        NSLog(@"Failed to set personal information");
    }];
}


- (void)getFirmwareInfo {
    NSLog(@"Get firmware information");
    [QCSDKCmdCreator getDeviceSoftAndHardVersionSuccess:^(NSString * _Nonnull hardVersion, NSString * _Nonnull softVersion) {
        NSLog(@"Obtaining firmware information successfully, hardware version: %@, firmware version: %@",hardVersion,softVersion);
    } fail:^{
        NSLog(@"Failed to get firmware information");
    }];
}

- (void)getPower {
    NSLog(@"Get battery information");
    [QCSDKCmdCreator readBatterySuccess:^(int battery) {
        NSLog(@"Obtained battery information successfully:%d",battery);
    } failed:^{
        NSLog(@"Failed to get battery information");
    }];
}

- (void)getSleep {
    NSLog(@"Get sleep data");
    //7 days
    //dayIndex: 0-6,0:today,1:yesterday ...
    [QCSDKCmdCreator getSleepDetailDataByDay:0 sleepDatas:^(NSArray<QCSleepModel *> * _Nonnull sleeps) {
        NSLog(@"Get sleep data successfully");
        NSInteger total = 0;
        for (QCSleepModel *sleep in sleeps) {
            NSLog(@"Start Time:%@,End Tile:%@,duration:%ld,type:%ld",sleep.happenDate,sleep.endTime,sleep.total,sleep.type);
            total = total + sleep.total;
        }
        
        NSLog(@"total duration：%ldh%ldm",total/60,total%60);
    } fail:^{
        NSLog(@"Failed to get sleep");
    }];
}

- (void)getSleepFromDay {
    NSLog(@"Get sleep data");
    [QCSDKCmdCreator getSleepDetailDataFromDay:1 sleepDatas:^(NSDictionary <NSString*,NSArray<QCSleepModel*>*>* _Nonnull sleeps) {
        NSLog(@"Get sleep data successfully");
        for (NSString *dayText in sleeps.allKeys) {
            NSLog(@"sleep date:%@",dayText);
            NSArray *daySleeps = [sleeps valueForKey:dayText];
            NSInteger total = 0;
            for (QCSleepModel *sleep in daySleeps) {
                NSLog(@"Start Time: %@, End Time: %@, Duration: %ld, Type: %ld",sleep.happenDate,sleep.endTime,sleep.total,sleep.type);
                total = total + sleep.total;
            }
            NSLog(@"total duration：%ldh%ldm",total/60,total%60);
        }
    } fail:^{
        NSLog(@"Failed to get sleep");
    }];
}

- (void)getHeartRate {
        
    //Schedule Heart Rate: Measure heart rate every 5 minutes
    [QCSDKCmdCreator getSchedualHeartRateStatusWithSuccess:^(BOOL enable) {
       
        NSLog(@"Schedule Heart Rate Switch state is %@",enable?@"NO":@"OFF");
        
        //Schedual HeartRate
        //Day Index: 7 days==>0:today,1:yesterday...
        [QCSDKCmdCreator getSchedualHeartRateDataWithDayIndexs:@[@(0)] success:^(NSArray<QCSchedualHeartRateModel *> * _Nonnull schedualData) {
            
            NSLog(@"Schedual HeartRate data count:%ld",schedualData.count);
            
            
            //Manual HeartRate
            //Day Index: 7 days==>0:today,1:yesterday...
            [QCSDKCmdCreator getManualHeartRateDataByDayIndex:0 finished:^(NSArray<QCManualHeartRateModel *> * _Nullable manualData, NSError * _Nullable err) {
                
                NSLog(@"Manual HeartRate data count:%ld",manualData.count);
            }];
            
        } fail:^{
            
        }];
        
    } fail:^{
        
    }];
}

- (void)getSchedualHeartRateAndTimeInterval {
    
    //Get the status of the scheduled heart rate switch and the time interval of the scheduled heart rate
    //获取定时心率开关状态，以及定时心率的时间间隔
    [QCSDKCmdCreator getSchedualHeartRateStatusAndIntervalWithSuccess:^(BOOL enable, NSInteger interval) {
       
        NSLog(@"schedual HeartRate Status:%d,timeInterval:%lu",enable,interval);
        
        
        //Set the status of the scheduled heart rate switch and the time interval of the scheduled heart rate
        //获取定时心率开关状态，以及定时心率的时间间隔
        [QCSDKCmdCreator setSchedualHeartRateStatus:YES timeInterval:5 success:^{
            
        } fail:^{
            
        }];
                
    } fail:^{
        
    }];
}

- (void)getBloodPressure {
    
    //1.Some watches support it, and setting the time will return the status of whether it is supported
    [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary * _Nonnull info) {
        
        if([[info objectForKey:QCBandFeatureBloodPressure] boolValue]) {
            NSLog(@"Supperort Blood Pressure");
            
            //2.Schedule Blood Pressure
            
            //3.Get Schedule Blood Pressure switch state（Measure blood pressure every one hour）
            [QCSDKCmdCreator getSchedualBPInfo:^(BOOL featureOn, NSString * _Nonnull beginTime, NSString * _Nonnull endTime, NSInteger minuteInterval) {
                
                if(featureOn) {
                    NSLog(@"Schedual Blood Pressure is On");
                }
                else {
                    NSLog(@"Schedual Blood Pressure is Off");
                }
                
                //minuteInterval: limit to 120 minutes
                [QCSDKCmdCreator setSchedualBPInfoOn:YES beginTime:@"00:00" endTime:@"23:59" minuteInterval:60 success:^(BOOL featureOn, NSString * _Nonnull beginTime, NSString * _Nonnull endTime, NSInteger minuteInterval) {
                    
                    
                    //4.Get Schedule Blood Pressure hisitroy Data(last 7 days)
                    [QCSDKCmdCreator getSchedualBPHistoryDataWithSuccess:^(NSArray<QCBloodPressureModel *> * _Nonnull data) {
                        
                        NSLog(@"Schedual Blood Pressure datas:%ld",[data count]);
                        
                        //5.Get Manual Blood Pressure
                        [QCSDKCmdCreator getManualBloodPressureDataWithLastUnixSeconds:0 success:^(NSArray<QCBloodPressureModel *> * _Nonnull data) {
                            
                            NSLog(@"Manual Blood Pressure datas:%ld",[data count]);
                            
                        } fail:^{
                            
                        }];
                        
                        
                    } fail:^{
                        
                    }];
                    
                    
                } fail:^{
                    
                }];
                
            } fail:^{
                
            }];
        }
        else {
            NSLog(@"Not Supperort Blood Pressure");
        }
        
    } failed:^{

        
    }];
    
}

- (void)getBloodOxygen {
    
    //1.Some watches support it, and setting the time will return the status of whether it is supported
    [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary * _Nonnull info) {
        
        if([[info objectForKey:QCBandFeatureBloodOxygen] boolValue]) {
            NSLog(@"Supperort Blood Pressure");
            
            //2.Schedule Blood Oxygen
            
            //3.Get Schedule Blood Oxygen switch state（Measure blood pressure every one hour）
            [QCSDKCmdCreator getSchedualBOInfoSuccess:^(BOOL featureOn) {
                
//                if(featureOn) {
//                    NSLog(@"Schedual Blood Oxygen is On");
//                }
//                else {
//                    NSLog(@"Schedual Blood Oxygen is Off");
//                }
                
                [QCSDKCmdCreator setSchedualBOInfoOn:YES success:^(BOOL featureOn) {
                    
                    NSLog(@"set Schedual Blood Oxygen success");
                    
//                    //4.Get Schedule Blood Oxygen hisitroy Data(last 7 days)
//                    //Day index: 0-6 ,0:today,1:yesterday...
//                    [QCSDKCmdCreator getBloodOxygenDataByDayIndex:0 finished:^(NSArray * _Nullable data, NSError * _Nullable err) {
//                        if(err == nil) {
//                            NSLog(@"Schedual Blood Pressure datas:%ld",[data count]);
//                        }
//                    }];
                    
                } fail:^{
                    NSLog(@"set Schedual Blood Oxygen fail");
                }];
                                
            } fail:^{
                
            }];
        }
        else {
            NSLog(@"Not Supperort Blood Pressure");
        }
        
    } failed:^{
        
        
    }];
}

- (void)getBodyTemperature {
    //1.Some watches support it, and setting the time will return the status of whether it is supported
    [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary * _Nonnull info) {
        
        if([[info objectForKey:QCBandFeatureTemperature] boolValue]) {
            NSLog(@"Supperort Body Temperature");
            
            //2.Get Schedual Body Temperature hisitroy Data(last 7 days)
            //Day index: 0-6 ,0:today,1:yesterday...
            [QCSDKCmdCreator getSchedualTemperatureDataByDayIndex:0 finished:^(NSArray * _Nullable temperatureList, NSError * _Nullable error) {
                NSLog(@"Schedual Body Temperature datas:%ld",[temperatureList count]);
                
                
                //3.Get Manual Body Temperature
                [QCSDKCmdCreator getManualTemperatureDataByDayIndex:0 finished:^(NSArray * _Nullable temperatureList, NSError * _Nullable error) {
                    NSLog(@"Manual Body Temperature datas:%ld",[temperatureList count]);
                }];
            }];
        }
        else {
            NSLog(@"Not Supperort Blood Pressure");
        }
        
    } failed:^{
        
        
    }];
}

- (void)getBloodGlucouse {
    //1.Some watches support it, and setting the time will return the status of whether it is supported
    [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary * _Nonnull info) {
        if([[info objectForKey:QCBandFeatureBloodGlucose] boolValue]) {
            
            //
            [QCSDKCmdCreator getBloodGlucoseDataByDayIndex:0 finished:^(NSArray * _Nullable data, NSError * _Nullable err) {
                
            }];
        }
        
    } failed:^{
        
    }];
}


- (void)takePicture {
    NSLog(@"start taking pictures");
    [QCSDKCmdCreator switchToPhotoUISuccess:^{

    } fail:^{

    }];
}

- (void)DFUUpdate {
    
    __block int p = -1;
    NSLog(@"🌟Please make sure the firmware file corresponds to the device, R02A_2.06.06_240302 corresponds to R02A🌟");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"R02A_2.06.06_240302" ofType:@"bin"]; //R02A_2.06.06_240302
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    [QCSDKCmdCreator syncOtaBinData:data start:^{
        NSLog(@"Start firmware upgrade");
    } percentage:^(int percentage) {
        if (p != percentage && percentage%10==0) {
            p = percentage;
            NSLog(@"firmware progress:%ld",(long)percentage);
        }
    } success:^(int seconds) {
        NSLog(@"Firmware upgrade is successful, time:%lds",(long)seconds);
    } failed:^(NSError * _Nonnull error) {
        NSLog(@"Firmware upgrade failed");
    }];
}



- (void)getSteps {
    NSLog(@"🌟Get pedometer data🌟");
    [QCSDKCmdCreator getSportDetailDataByDay:0 sportDatas:^(NSArray<QCSportModel *> * _Nonnull sports) {
        NSLog(@"Get step count data details");
        NSInteger totalStepCount = 0;
        double calories = 0;
        NSInteger distance = 0;
        
        for (QCSportModel *model in sports) {
            totalStepCount += model.totalStepCount;
            calories += model.calories;
            distance += model.distance;
            NSLog(@"Pedometer data details:%@,totalStepCount：%zd,calories:%lf,distance：%zd",model.happenDate,model.totalStepCount,model.calories,model.distance);
        }
        NSLog(@"Pedometer data details result:totalStepCount：%zd,calories:%lf,distance：%zd",totalStepCount,calories,distance);
        
        [QCSDKCmdCreator getCurrentSportSucess:^(QCSportModel * _Nonnull sport) {
            
            NSLog(@"Pedometer data summary:totalStepCount：%zd,calories:%lf,distance：%zd",sport.totalStepCount,sport.calories,sport.distance);
        } failed:^{
            
        }];
        
    } fail:^{
        
    }];
}

- (void)hrMeasuringAction {
    
    NSLog(@"🌟Start heart rate measurement🌟");
    //1.Some watches support it, and setting the time will return the status of whether it is supported
    //2.All rings are supported, no judgment required
    [QCSDKCmdCreator setTime:[NSDate date] success:^(NSDictionary * _Nonnull info) {
        
        //A single measurement initiated by the App to the ring
        //App向戒指发起的单次测量
        if([[info objectForKey:QCBandFeatureAppManual] boolValue]) {
            NSLog(@"Supperort ");            
            
            QCMeasuringType operateType = QCMeasuringTypeHeartRate;
            [[QCSDKManager shareInstance] startToMeasuringWithOperateType:operateType measuringHandle:^(id  _Nullable result) {
                
                if (result != nil && [result isKindOfClass:[NSNumber class]]) {
                    NSInteger value = [(NSNumber*)result integerValue];
                    NSLog(@"current measuring value:%zd",value);
                }
                
            } completedHandle:^(BOOL isSuccess, id  _Nonnull result, NSError * _Nonnull error) {
               
                NSLog(@"blood oxygen measurement results：%@",result);
                if (isSuccess) {
                    NSLog(@"heart rate measurement：%zd",[(NSNumber*)result integerValue]);
                    //NSLog(@"blood pressure measurement：%@",result);
                    //NSLog(@"blood oxygen measurement results：%lf",[(NSNumber*)result floatValue]);
                    NSLog(@"blood oxygen measurement results：%@",result);
                }
                else {
                    NSLog(@"Measurement failed");
                }
            }];
            
        //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        [[QCSDKManager shareInstance] stopToMeasuringWithOperateType:operateType completedHandle:^(BOOL isSuccess, NSError * _Nonnull error) {
        //            //[self hrMeasuringAction];
        //            NSLog(@"++++");
        //        }];
        //    });
            
        }
        else {
            NSLog(@"Not Supperort ");
        }
        
    } failed:^{
        
        
    }];
    

}

- (void)getSportRecords {
    
    [QCSDKCmdCreator getSportRecordsFromLastTimeStamp:0 finish:^(NSArray<OdmGeneralExerciseSummaryModel *> * _Nullable summaries, NSError * _Nullable error) {
       
        NSLog(@"getSportRecords Finish");
        for (OdmGeneralExerciseSummaryModel *model in summaries) {
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:model.startTime];
            
            //Convert TimeZone
            startDate = [self convertTimeZone:startDate];
                        
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSLog(@"date:%@,steps:%zd,hr count:%zd",[dateFormatter stringFromDate:startDate],model.steps,model.detail.hrs.count);
            /*
            2023-02-28 14:00:15.030554+0800 QCBandSDKDemo[6223:262521] date:2023-02-24 16:58:39,steps:2470,hr count:47
            2023-02-28 14:00:15.032183+0800 QCBandSDKDemo[6223:262521] date:2023-02-23 21:19:04,steps:0,hr count:54
            2023-02-28 14:00:15.034040+0800 QCBandSDKDemo[6223:262521] date:2023-02-23 21:16:34,steps:0,hr count:52
            2023-02-28 14:00:15.035666+0800 QCBandSDKDemo[6223:262521] date:2023-02-23 21:06:38,steps:303,hr count:56
             */
        }
    }];
}

- (void)startToRealTimeHR {
    
    NSLog(@"start RealTime HeartRate");
    //[self endToRealTimeHR];
    
    //start RealTime HeartRate
    [QCSDKCmdCreator realTimeHeartRateWithCmd:(QCBandRealTimeHeartRateCmdTypeStart) finished:nil];
    
    
     //RealTime HeartRate Result
     
     [QCSDKManager shareInstance].realTimeHeartRate = ^(NSInteger hr){
         NSLog(@"The RealTime HeartRate is :%zd",hr);
     };
    
    
    //hold RealTime HeartRate
    [self startToHoldTealTimeHRTimer];
    
    
    //stop RealTime HeartRate
    [self performSelector:@selector(endToRealTimeHR) withObject:nil afterDelay:kQCHoldRealTimeHeartRateTimeout*6];
}

- (void)endToRealTimeHR {
    NSLog(@"end RealTime HeartRate");
    [self stopTimer];
    [QCSDKCmdCreator realTimeHeartRateWithCmd:(QCBandRealTimeHeartRateCmdTypeEnd) finished:nil];
}

- (void)holdTealTimeHR {
    NSLog(@"hold RealTime RealTime HeartRate");
    [QCSDKCmdCreator realTimeHeartRateWithCmd:(QCBandRealTimeHeartRateCmdTypeHold) finished:nil];
}

- (void)startToHoldTealTimeHRTimer {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kQCHoldRealTimeHeartRateTimeout target:self selector:@selector(holdTealTimeHR) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)getStress {
    //Only Ring Supports
    [QCSDKCmdCreator getSchedualStressStatusWithFinshed:^(BOOL isOn, NSError * _Nullable error) {
        
        
        //get stress datas
        [QCSDKCmdCreator getSchedualStressDataWithDates:@[@(0),@(1),@(2),@(3),@(4),@(5),@(6)] finished:^(NSArray * _Nullable models, NSError * _Nullable err) {
                        
            if (err == nil) {
                NSLog(@"Stress data count:%zd",models.count);
            }
            
        }];
    }];
}

- (void)operateSportModel {
    //Only Ring Supports
    /*
     //Supported by Ring
     //App send start sport cmd
     [QCSDKManager shareInstance].currentSportInfo = ^(QCSportInfoModel * _Nonnull sportInfo) {
         NSLog(@"sportType:%zd,duration:%zd,state:%u,hr:%zd,step:%zd,calorie(unit:calorie):%zd,distance(unit:meter):%zd",sportInfo.sportType,sportInfo.duration,sportInfo.state,sportInfo.hr,sportInfo.step,sportInfo.calorie,sportInfo.distance);
     };
     */
    
    [QCSDKCmdCreator operateSportModeWithType:(OdmSportPlusExerciseModelTypeWalk) state:(QCSportStateStart) finish:^(id _Nullable res, NSError * _Nullable err) {
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [QCSDKCmdCreator operateSportModeWithType:OdmSportPlusExerciseModelTypeWalk state:(QCSportStateStop) finish:^(id _Nullable res, NSError * _Nullable err) {
                
                //get sport records
                [self getSportRecords];
                
            }];
        });
    }];
}

- (NSDate*)convertTimeZone:(NSDate*)date {
    NSTimeZone * Shanghai = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    NSTimeInterval a = Shanghai.secondsFromGMT - [[NSTimeZone systemTimeZone] secondsFromGMT];
    return [date dateByAddingTimeInterval:a];
}

#pragma mark - CollectionView view datasource & delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return QCFeatureTypeCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewFeatureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionViewFeatureCell class]) forIndexPath:indexPath];
    
    cell.featureName = [[self class] featureNameWithType:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case QCFeatureTypeAlertBinding:
            [self setAlertBinding];
            break;
        case QCFeatureTypeSetTime:
            [self setTime];
            break;
        case QCFeatureTypeSetMyProfile:
            [self setMyProfile];
            break;
        case QCFeatureTypeGetFirmware:
            [self getFirmwareInfo];
            break;
        case QCFeatureTypeGetPower:
            [self getPower];
            break;
        case QCFeatureTypeSleepByDay:
            [self getSleep];
            break;
        case QCFeatureTypeSleepFromDay:
            [self getSleepFromDay];
            break;
        case QCFeatureTypeTakePicture:
            [self takePicture];
            break;
        case QCFeatureTypeDFUUpdate:
            [self DFUUpdate];
            break;
        case QCFeatureTypeGetSteps:
            [self getSteps];
            break;
        case QCFeatureTypeHRMeasuring:
            [self hrMeasuringAction];
            break;
        case QCFeatureTypeGetSportRecords:
            [self getSportRecords];
            break;
        case QCFeatureTypeRealTimeHeartRateStart:
            [self startToRealTimeHR];
            break;
        default:
            break;
    }
}


#pragma mark - Helpers
- (NSString *)macFromAdvertisementData:(NSDictionary *)advertisementData {
    NSString *mac = @"";
    NSData *manufacturerData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    mac = [self macFromData:manufacturerData];
    
    if (mac.length == 0) {
        NSDictionary *serviceData = [advertisementData objectForKey:@"kCBAdvDataServiceData"];
        if ([serviceData isKindOfClass:[NSDictionary class]]) {
            NSArray *allValues = [serviceData allValues];
            if (allValues.count > 0) {
                for (NSData *dataValue in allValues) {
                    if ([dataValue isKindOfClass:[NSData class]]) {
                        mac = [self macFromData:dataValue];
                    }
                }
            }
        }
    }
    return mac;
}

- (NSString*)macFromData:(NSData*)macData {
    NSString *mac = @"";
    if ([macData isKindOfClass:[NSData class]] && macData.length > 0) {
        NSData *data = macData;
        if (data.length >= 10) {
            data = [data subdataWithRange:NSMakeRange(4, 6)];
            Byte *bytes = (Byte *)data.bytes;
            mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                        bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
        } else if (data.length == 8) {
            data = [data subdataWithRange:NSMakeRange(2, 6)];
            Byte *bytes = (Byte *)data.bytes;
            mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                        bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
        } else if (data.length == 6) {
           data = [data subdataWithRange:NSMakeRange(0, 6)];
           Byte *bytes = (Byte *)data.bytes;
           mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                       bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
       }
    }
    
    return mac;
}

+ (NSString*)featureNameWithType:(QCFeatureType)type {
    
    switch (type) {
        case QCFeatureTypeAlertBinding:
            return @"Alert Binding";
        case QCFeatureTypeSetTime:
            return @"Set Time";
        case QCFeatureTypeSetMyProfile:
            return @"Set Profile";
        case QCFeatureTypeGetFirmware:
            return @"Get Firmware";
        case QCFeatureTypeGetPower:
            return @"Get Battery";
        case QCFeatureTypeSleepByDay:
            return @"One day Sleep";
        case QCFeatureTypeSleepFromDay:
            return @"Some days Sleep";
        case QCFeatureTypeTakePicture:
            return @"Take Pciture";
        case QCFeatureTypeDFUUpdate:
            return @"Firmware Upgrade";
        case QCFeatureTypeGetSteps:
            return @"Get Steps";
        case QCFeatureTypeHRMeasuring:
            return @"Heart Rate Measuring";
        case QCFeatureTypeGetSportRecords:
            return @"Sport Records";
        case QCFeatureTypeRealTimeHeartRateStart:
            return @"Start RealTime HR";
        default:
            break;
    }
    
    return @"Title";
}
@end
