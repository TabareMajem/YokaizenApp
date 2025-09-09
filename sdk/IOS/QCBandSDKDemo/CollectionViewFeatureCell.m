//
//  CollectionViewFeatureCell.m
//  QCBandSDKDemo
//
//  Created by steve on 2021/7/7.
//

#import "CollectionViewFeatureCell.h"

@interface CollectionViewFeatureCell()

@property(nonatomic,strong)UILabel *featureLabel;
@end

@implementation CollectionViewFeatureCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _featureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _featureLabel.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:152.0/255.0 blue:18.0/255.0 alpha:1];
        _featureLabel.textAlignment = NSTextAlignmentCenter;
        _featureLabel.textColor = [UIColor whiteColor];
        _featureLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:_featureLabel];
    }
    return self;
}

#pragma mark - Setter & Getter
- (void)setFeatureName:(NSString *)featureName {
    _featureName = featureName;
    
    self.featureLabel.text = featureName;
}

@end

