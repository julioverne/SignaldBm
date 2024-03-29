#import "Tweak.h"

static BOOL Enabled;
static BOOL rssi_wifi;
static BOOL rssi_cell;

static int textColor;
static float fontSize;
static float kHeight;
static float kWidth;
static float kAlphaText;

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
		self.updater = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatedBmValue) userInfo:nil repeats:YES];
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
				self.labelSignaldBm.textColor = textColor==0?[UIColor whiteColor]:textColor==1?[UIColor blackColor]:[UIColor redColor];
				if(fontSize > 0) {
					self.labelSignaldBm.font = [self.labelSignaldBm.font fontWithSize:fontSize];
					[self.labelSignaldBm setAdjustsFontSizeToFitWidth:NO];
				}
				if(kAlphaText > 0) {
					self.labelSignaldBm.alpha = kAlphaText;
				}
			}
			self.labelSignaldBm.isWiFi = YES;
			self.labelSignaldBm.tag = 233;
			
			self.labelSignaldBm.frame = CGRectMake(0, 0, kWidth>0?kWidth:self.frame.size.width, kHeight>0?kHeight:self.frame.size.width);
			self.labelSignaldBm.center = self.center;
			
			
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
				self.labelSignaldBm.textColor = textColor==0?[UIColor whiteColor]:textColor==1?[UIColor blackColor]:[UIColor redColor];
				if(fontSize > 0) {
					self.labelSignaldBm.font = [self.labelSignaldBm.font fontWithSize:fontSize];
					[self.labelSignaldBm setAdjustsFontSizeToFitWidth:NO];
				}
				if(kAlphaText > 0) {
					self.labelSignaldBm.alpha = kAlphaText;
				}
			}
			self.labelSignaldBm.isWiFi = NO;
			self.labelSignaldBm.tag = 234;
			
			self.labelSignaldBm.frame = CGRectMake(0, 0, kWidth>0?kWidth:self.frame.size.width, kHeight>0?kHeight:self.frame.size.width);
			self.labelSignaldBm.center = self.center;
			
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
		textColor = (int)[Prefs[@"textColor"]?:@(0) intValue];
		fontSize = (float)[Prefs[@"fontSize"]?:@(0) floatValue];
		kWidth = (float)[Prefs[@"kWidth"]?:@(0) floatValue];
		kHeight = (float)[Prefs[@"kHeight"]?:@(0) floatValue];
		kAlphaText = (float)[Prefs[@"kAlphaText"]?:@(1.0) floatValue];
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
