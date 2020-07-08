
#define NSLog(...)

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.signaldbm.plist"


@interface WFLinkQuality : NSObject
@property (assign) NSInteger rssi;
@end

@interface WFWiFiStateMonitor : NSObject
@property (nonatomic,retain) WFLinkQuality* linkQuality;
@end

@interface CTXPCServiceSubscriptionContext : NSObject
+(id)contextWithSlot:(long long)arg1 ;
@end

@interface CoreTelephonyClient : NSObject
- (id)getSignalStrengthMeasurements:(id)arg1 error:(id*)arg2;
- (id)getSignalStrengthInfo:(id)arg1 error:(id*)arg2 ;
@end

@interface CTSignalStrengthMeasurements : NSObject
@property (nonatomic,retain) NSNumber * rsrp;
@end

@interface CTServiceDescriptor : NSObject
+ (id)descriptorWithSubscriptionContext:(id)arg1 ;
@end

@interface SBTelephonyManager : NSObject
@property (nonatomic,retain) CoreTelephonyClient * coreTelephonyClient;
+ (id)sharedTelephonyManager;
@end

@interface UILabelSignaldBm : UILabel
@property (assign) BOOL isWiFi;
@property (nonatomic) NSTimer * updater;
- (void)updatedBmValue;
@end

@interface _UIStatusBarCellularSignalView : UIView
@property (nonatomic,retain) UILabelSignaldBm* labelSignaldBm;
@end 

@interface _UIStatusBarWifiSignalView : UIView
@property (nonatomic,retain) UILabelSignaldBm* labelSignaldBm;
@end 


