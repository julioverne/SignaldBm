#import "Tweak.h"

static BOOL Enabled;
static BOOL rssi_wifi;
static BOOL rssi_cell;

static WFWiFiStateMonitor* WFMonitor;
static NSString* getCurrentWiFidBm()
{
	NSString* ret = nil;
	@try {
		if(!WFMonitor) {
			WFMonitor = [[%c(WFWiFiStateMonitor) alloc] init];
		}
		NSInteger valRssi = WFMonitor.linkQuality.rssi;
		if(valRssi < 0) {
			ret = [NSString stringWithFormat:@"%d", (int)valRssi];
		}
	} @catch(NSException*e) {
	}
	return ret;
}

static NSString* getCurrentCelldBm()
{
	NSString* ret = nil;
	@try {
		SBTelephonyManager* shr = [%c(SBTelephonyManager) sharedTelephonyManager];
		CoreTelephonyClient* client = shr.coreTelephonyClient;
		id context = [%c(CTXPCServiceSubscriptionContext) contextWithSlot:1];
		CTServiceDescriptor* desc = [%c(CTServiceDescriptor) descriptorWithSubscriptionContext:context];
		CTSignalStrengthMeasurements* measurements = [client getSignalStrengthMeasurements:desc error:nil];
		NSInteger valRssi = 0;
		if(measurements) {
			valRssi = [measurements.rsrp?:@(0) intValue];
		}
		if(valRssi != 0) {
			ret = [NSString stringWithFormat:@"%d", (int)valRssi];
		}
	} @catch(NSException*e) {
	}
	return ret;
}

@implementation UILabelSignaldBm
@synthesize isWiFi, updater;
- (id)init
{
	self = [super init];
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		self.updater = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                           target:self
                                         selector:@selector(updatedBmValue)
                                         userInfo:nil
                                          repeats:YES];
	});
	
	[self setAdjustsFontSizeToFitWidth:YES];
	
	return self;
}
- (void)updatedBmValue
{
	self.text = self.isWiFi?getCurrentWiFidBm():getCurrentCelldBm();
}
- (void)dalloc
{
	if(self.updater && [self.updater isValid]) {
		[self.updater invalidate];
	}
}
@end



%hook _UIStatusBarWifiSignalView
%property (retain) id labelSignaldBm;
- (void)_updateBars
{
	if(Enabled&&rssi_wifi) {
		if(self.labelSignaldBm) {
			[self.labelSignaldBm updatedBmValue];
		}
		return; // no draw bars
	}
	%orig;
}
- (void)_updateCycleAnimationNow
{
	if(Enabled&&rssi_wifi) {
		if(self.labelSignaldBm) {
			[self.labelSignaldBm updatedBmValue];
		}
		return; // no draw bars
	}
	%orig;
}
- (void)layoutSubviews
{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIView* vAdd = [self superview];
		if(UIView* oldV = [vAdd viewWithTag:233]) {
			[oldV removeFromSuperview];
		}
		if(Enabled&&rssi_wifi) {
			if(!self.labelSignaldBm) {
				self.labelSignaldBm = [[UILabelSignaldBm alloc] init];
			}
			self.labelSignaldBm.isWiFi = YES;
			self.labelSignaldBm.tag = 233;
			self.labelSignaldBm.frame = self.frame;
			[self.labelSignaldBm updatedBmValue];
			[vAdd addSubview:self.labelSignaldBm];
		}
	});
}
%end

%hook _UIStatusBarCellularSignalView
%property (retain) id labelSignaldBm;
- (void)_updateBars
{
	if(Enabled&&rssi_cell) {
		if(self.labelSignaldBm) {
			[self.labelSignaldBm updatedBmValue];
		}
		return; // no draw bars
	}
	%orig;
}
- (void)_updateCycleAnimationNow
{
	if(Enabled&&rssi_cell) {
		if(self.labelSignaldBm) {
			[self.labelSignaldBm updatedBmValue];
		}
		return; // no draw bars
	}
	%orig;
}
- (void)layoutSubviews
{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIView* vAdd = [self superview];
		if(UIView* oldV = [vAdd viewWithTag:234]) {
			[oldV removeFromSuperview];
		}
		if(Enabled&&rssi_cell) {
			if(!self.labelSignaldBm) {
				self.labelSignaldBm = [[UILabelSignaldBm alloc] init];
			}
			self.labelSignaldBm.isWiFi = NO;
			self.labelSignaldBm.tag = 234;
			self.labelSignaldBm.frame = self.frame;
			[self.labelSignaldBm updatedBmValue];
			[vAdd addSubview:self.labelSignaldBm];
		}
	});
}
%end



static void settingsChangedSignaldBm(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {
		NSDictionary *Prefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:@{} copy];
		Enabled = (BOOL)[Prefs[@"Enabled"]?:@YES boolValue];
		rssi_wifi = (BOOL)[Prefs[@"rssi_wifi"]?:@YES boolValue];
		rssi_cell = (BOOL)[Prefs[@"rssi_cell"]?:@YES boolValue];
	}
}


%ctor
{
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedSignaldBm, CFSTR("com.julioverne.signaldbm/SettingsChanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		settingsChangedSignaldBm(NULL, NULL, NULL, NULL, NULL);
		dlopen("/System/Library/PrivateFrameworks/WiFiKit.framework/WiFiKit", RTLD_LAZY);		
		%init;
	}
}
