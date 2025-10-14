//
//  ViewController.m
//  QCSDKDemo
//
//  Created by steve on 2025/7/22.
//

#import "ViewController.h"
#import <QCSDK/QCVersionHelper.h>
#import <QCSDK/QCSDKManager.h>
#import <QCSDK/QCSDKCmdCreator.h>
#import "GlassesMediaDownloader.h"
#import "MediaGalleryViewController.h"
        
#import "QCScanViewController.h"
#import "QCCentralManager.h"
#import <NetworkExtension/NetworkExtension.h>

typedef NS_ENUM(NSInteger, QGDeviceActionType) {
    /// Get hardware version, firmware version, and WiFi firmware versions
    QGDeviceActionTypeGetVersion = 0,

    /// Set the current device time
    QGDeviceActionTypeSetTime,

    /// Get battery level and charging status
    QGDeviceActionTypeGetBattery,

    /// Get the number of photos, videos, and audio files on the device
    QGDeviceActionTypeGetMediaInfo,

    /// Trigger the device to take a photo
    QGDeviceActionTypeTakePhoto,

    /// Start or stop video recording
    QGDeviceActionTypeToggleVideoRecording,

    /// Start or stop audio recording
    QGDeviceActionTypeToggleAudioRecording,

    /// Take AI Image
    QGDeviceActionTypeToggleTakeAIImage,

    /// Switch to Capture Mode
    QGDeviceActionTypeSwitchToCaptureMode,

    /// Switch to Transfer Mode
    QGDeviceActionTypeSwitchToTransferMode,

    /// Download media over Wi-Fi
    QGDeviceActionTypeDownloadMedia,

    /// View downloaded media gallery
    QGDeviceActionTypeViewGallery,

    /// Reserved for future use
    QGDeviceActionTypeReserved,
};



@interface ViewController ()<UITableViewDelegate, UITableViewDataSource,QCCentralManagerDelegate,QCSDKManagerDelegate>

@property(nonatomic,strong)UIBarButtonItem *rightItem;
@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)GlassesMediaDownloader *mediaDownloader;
@property(nonatomic,copy)NSString *mediaDownloadStatus;
@property(nonatomic,strong)UIImage *latestDownloadedMediaPreview;
@property(nonatomic,copy)NSString *glassesDeviceIP;
@property(nonatomic,strong)NSString *glassesSSID;
@property(nonatomic,strong)NSString *glassesPassword;

@property(nonatomic,copy)NSString *hardVersion;
@property(nonatomic,copy)NSString *firmVersion;
@property(nonatomic,copy)NSString *hardWiFiVersion;
@property(nonatomic,copy)NSString *firmWiFiVersion;

@property(nonatomic,copy)NSString *mac;

@property(nonatomic,assign)NSInteger battary;
@property(nonatomic,assign)BOOL charging;

@property(nonatomic,assign)NSInteger photoCount;
@property(nonatomic,assign)NSInteger videoCount;
@property(nonatomic,assign)NSInteger audioCount;

@property(nonatomic,assign)BOOL recordingVideo;
@property(nonatomic,assign)BOOL recordingAudio;

@property(nonatomic,strong)NSData *aiImageData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Feature(Tap to get data)";
    
    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                      style:(UIBarButtonItemStylePlain)
                                                     target:self
                                                     action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = self.rightItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    [QCSDKManager shareInstance].delegate = self;
}

#pragma mark - Device Data Report
- (void)didUpdateBatteryLevel:(NSInteger)battery charging:(BOOL)charging {
    self.battary = battery;
    self.charging = charging;
    [self.tableView reloadData];
}

- (void)didUpdateMediaWithPhotoCount:(NSInteger)photo videoCount:(NSInteger)video audioCount:(NSInteger)audio type:(NSInteger)type {
    
    self.photoCount = photo;
    self.videoCount = video;
    self.audioCount = audio;
    [self.tableView reloadData];
}

- (void)didReceiveAIChatImageData:(NSData *)imageData {
    NSLog(@"didReceiveAIChatImageData");
    self.aiImageData = imageData;
    [self.tableView reloadData];
}

#pragma mark - Feature Fuctions
- (void)getHardVersionAndFirmVersion {
    [QCSDKCmdCreator getDeviceVersionInfoSuccess:^(NSString * _Nonnull hdVersion, NSString * _Nonnull firmVersion, NSString * _Nonnull hdWifiVersion, NSString * _Nonnull firmWifiVersion) {
        
        self.hardVersion = hdVersion;
        self.firmVersion = firmVersion;
        self.hardWiFiVersion = hdWifiVersion;
        self.firmWiFiVersion = firmWifiVersion;
        [self.tableView reloadData];
        NSLog(@"hard Version:%@",hdVersion);
        NSLog(@"firm Version:%@",firmVersion);
        NSLog(@"hard Wifi Version:%@",hdWifiVersion);
        NSLog(@"firm Wifi Version:%@",firmWifiVersion);
    } fail:^{
        NSLog(@"get version fail");
    }];
}

- (void)getMacAddress {
    //[QCSDKCmdCreator get
    [QCSDKCmdCreator getDeviceMacAddressSuccess:^(NSString * _Nullable macAddress) {
        self.mac = macAddress;
        [self.tableView reloadData];
    } fail:^{
        NSLog(@"get mac address fail");
    }];
}

- (void)setTime {
    [QCSDKCmdCreator setupDeviceDateTime:^(BOOL isSuccess, NSError * _Nullable err) {
        if (err) {
            NSLog(@"get err fail");
        }
    }];
}

- (void)getBattary {
    [QCSDKCmdCreator getDeviceBattery:^(NSInteger battary, BOOL charging) {
        
        self.battary = battary;
        self.charging = charging;
        [self.tableView reloadData];
    } fail:^{
        
    }];
}

- (void)getMediaInfo {
    [QCSDKCmdCreator getDeviceMedia:^(NSInteger photo, NSInteger video, NSInteger audio, NSInteger type) {
        
        self.photoCount = photo;
        self.videoCount = video;
        self.audioCount = audio;
        [self.tableView reloadData];
    } fail:^{
        
    }];
}

- (void)takePhoto {
    //
    [QCSDKCmdCreator setDeviceMode:(QCOperatorDeviceModePhoto) success:^{
        
    } fail:^(NSInteger mode) {
        NSLog(@"set fail,current device model:%zd",mode);
    }];
}

- (void)recordVideo {
    
    if (self.recordingVideo) {
        
        [QCSDKCmdCreator setDeviceMode:(QCOperatorDeviceModeVideoStop) success:^{
            self.recordingVideo = NO;
            [self.tableView reloadData];
        } fail:^(NSInteger mode) {
            NSLog(@"set fail,current device model:%zd",mode);
        }];
    }
    else {
        [QCSDKCmdCreator setDeviceMode:(QCOperatorDeviceModeVideo) success:^{
            self.recordingVideo = YES;
            [self.tableView reloadData];
        } fail:^(NSInteger mode) {
            NSLog(@"set fail,current device model:%zd",mode);

        }];
    }
}

- (void)recordAudio {
    if (self.recordingVideo) {
        [QCSDKCmdCreator setDeviceMode:(QCOperatorDeviceModeAudioStop) success:^{
            self.recordingAudio = NO;
            [self.tableView reloadData];
        } fail:^(NSInteger mode) {
            NSLog(@"set fail,current device model:%zd",mode);
        }];
    } else {
        [QCSDKCmdCreator setDeviceMode:(QCOperatorDeviceModeAudio) success:^{
            self.recordingAudio = YES;
            [self.tableView reloadData];
        } fail:^(NSInteger mode) {
            NSLog(@"set fail,current device model:%zd",mode);
        }];
    }
}

- (void)takeAIImage {
    //- (void)didReceiveAIChatImageData:(NSData *)imageData
    [QCSDKCmdCreator setDeviceMode:(QCOperatorDeviceModeAIPhoto) success:^{
        
    } fail:^(NSInteger mode) {
        NSLog(@"set fail,current device model:%zd",mode);
    }];
}

#pragma mark - Actions
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
            self.tableView.hidden = YES;
            break;
        case QCStateConnecting:
            self.title = [QCCentralManager shared].connectedPeripheral.name;
            self.rightItem.title = @"Connecting";
            self.rightItem.enabled = NO;
            self.tableView.hidden = YES;
            break;
        case QCStateConnected:
            self.title = [NSString stringWithFormat:@"%@(Tap to get data)",[QCCentralManager shared].connectedPeripheral.name];
            self.rightItem.title = @"Unbind";
            self.rightItem.enabled = YES;
            self.tableView.hidden = NO;
            break;
        case QCStateUnkown:
            break;
        case QCStateDisconnecting:
        case QCStateDisconnected:
            self.rightItem.title = @"Search";
            self.rightItem.enabled = YES;
            self.tableView.hidden = YES;
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
    self.tableView.hidden = YES;
}

- (void)didFailConnected:(CBPeripheral *)peripheral {
    
    NSLog(@"didFailConnected");
    self.rightItem.enabled = YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return QGDeviceActionTypeReserved;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = nil;
    cell.detailTextLabel.text = @"";

    switch ((QGDeviceActionType)indexPath.row) {
        case QGDeviceActionTypeGetVersion:
            cell.textLabel.text = @"Get hard Version & firm Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"hardVersion:%@,\nfirmVersion:%@,\nhardWifiVersion:%@,\nfirmWifiVersion:%@", self.hardVersion, self.firmVersion, self.hardWiFiVersion, self.firmWiFiVersion];
            break;
        case QGDeviceActionTypeSetTime:
            cell.textLabel.text = @"Set Time";
            cell.detailTextLabel.text = @"";
            break;
        case QGDeviceActionTypeGetBattery:
            cell.textLabel.text = @"Get Battary";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"battary:%zd,charing:%zd", self.battary, (NSInteger)self.charging];
            break;
        case QGDeviceActionTypeGetMediaInfo:
            cell.textLabel.text = @"Get media info";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"photo:%zd,video:%zd,audio:%zd", self.photoCount, self.videoCount, self.audioCount];
            break;
        case QGDeviceActionTypeTakePhoto:
            cell.textLabel.text = @"Take Photo";
            break;
        case QGDeviceActionTypeToggleVideoRecording:
            cell.textLabel.text = self.recordingVideo ? @"Stop Recording Video" : @"Start Recording Video";
            break;
        case QGDeviceActionTypeToggleAudioRecording:
            cell.textLabel.text = self.recordingAudio ? @"Stop Record audio" : @"Start Record audio";
            break;
        case QGDeviceActionTypeToggleTakeAIImage:
            cell.textLabel.text = @"Take AI Image";
            if (self.aiImageData) {
                cell.imageView.image = [UIImage imageWithData:self.aiImageData];
            }
            break;
        case QGDeviceActionTypeDownloadMedia:
            cell.textLabel.text = @"Download Media Over Wi-Fi";
            cell.detailTextLabel.text = self.mediaDownloadStatus ?: @"Tap to download media files over the device hotspot.";
            if (self.latestDownloadedMediaPreview) {
                cell.imageView.image = self.latestDownloadedMediaPreview;
            }
            break;
        case QGDeviceActionTypeViewGallery:
            cell.textLabel.text = @"View Media Gallery";
            cell.detailTextLabel.text = @"Browse and view downloaded photos and videos.";
            break;
          case QGDeviceActionTypeReserved:
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QGDeviceActionType actionType = (QGDeviceActionType)indexPath.row;

    switch (actionType) {
        case QGDeviceActionTypeGetVersion:
            [self getHardVersionAndFirmVersion];
            break;
        case QGDeviceActionTypeSetTime:
            [self setTime];
            break;
        case QGDeviceActionTypeGetBattery:
            [self getBattary];
            break;
        case QGDeviceActionTypeGetMediaInfo:
            [self getMediaInfo];
            break;
        case QGDeviceActionTypeTakePhoto:
            [self takePhoto];
            break;
        case QGDeviceActionTypeToggleVideoRecording:
            [self recordVideo];
            break;
        case QGDeviceActionTypeToggleAudioRecording:
            [self recordAudio];
            break;
        case QGDeviceActionTypeToggleTakeAIImage:
            [self takeAIImage];
            break;
        case QGDeviceActionTypeDownloadMedia:
            [self downloadMediaOverWiFi];
            break;
        case QGDeviceActionTypeViewGallery:
            [self openMediaGallery];
            break;
        case QGDeviceActionTypeSwitchToCaptureMode:
            [self switchToCaptureMode];
            break;
        case QGDeviceActionTypeSwitchToTransferMode:
            [self switchToTransferMode];
            break;
        case QGDeviceActionTypeReserved:
        default:
            break;
    }

}

- (void)downloadMediaOverWiFi {
    __weak typeof(self) weakSelf = self;
    self.mediaDownloadStatus = @"Preparing Wi-Fi download...";
    self.latestDownloadedMediaPreview = nil;
    [self.tableView reloadData];

    self.mediaDownloader = [[GlassesMediaDownloader alloc] initWithStatusHandler:^(NSString *status, UIImage * _Nullable previewImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mediaDownloadStatus = status;
            if (previewImage) {
                weakSelf.latestDownloadedMediaPreview = previewImage;
            }
            [weakSelf.tableView reloadData];
        });
    }];

    [self.mediaDownloader startDownloadWithCompletion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.mediaDownloadStatus = [NSString stringWithFormat:@"Download failed: %@", error.localizedDescription ?: @"Unknown error"];
            } else {
                weakSelf.mediaDownloadStatus = @"Download complete.";
            }
            weakSelf.mediaDownloader = nil;
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)openMediaGallery {
    MediaGalleryViewController *galleryVC = [[MediaGalleryViewController alloc] init];

    // Set the media directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    NSString *mediaPath = [documentsDirectory stringByAppendingPathComponent:@"GlassesMedia"];
    galleryVC.mediaDirectoryPath = mediaPath;

    [self.navigationController pushViewController:galleryVC animated:YES];
}

- (void)switchToCaptureMode {
    // Try to switch directly to capture mode
    [QCSDKCmdCreator setDeviceMode:QCOperatorDeviceModePhoto success:^{
        NSLog(@"Successfully switched to capture mode");
        [self.tableView reloadData];
    } fail:^(NSInteger currentMode) {
        NSLog(@"Failed to switch to capture mode, current mode: %zd", currentMode);
        // If switching to photo mode fails, try switching to video mode first (often works as a reset)
        [QCSDKCmdCreator setDeviceMode:QCOperatorDeviceModeVideo success:^{
            NSLog(@"Successfully switched to video mode, now trying capture mode");
            [QCSDKCmdCreator setDeviceMode:QCOperatorDeviceModePhoto success:^{
                NSLog(@"Successfully switched to capture mode");
                [self.tableView reloadData];
            } fail:^(NSInteger finalMode) {
                NSLog(@"Still failed to switch to capture mode, current mode: %zd", finalMode);
                [self.tableView reloadData];
            }];
        } fail:^(NSInteger videoMode) {
            NSLog(@"Failed to switch to video mode, current mode: %zd", videoMode);
            [self.tableView reloadData];
        }];
    }];
}

- (void)switchToTransferMode {
    NSLog(@"🔥 Initiating transfer mode and WiFi connection...");

    __weak typeof(self) weakSelf = self;
    self.mediaDownloadStatus = @"Preparing glasses for WiFi transfer...";
    [self.tableView reloadData];

    // MARK: - HEYCYAN WiFi TRANSFER SEQUENCE
    // This is the documented HeyCyan Bluetooth-first WiFi transfer sequence
    // DO NOT MODIFY without updating documentation and testing all steps
    //
    // SEQUENCE STEPS:
    // 1. Bluetooth Connection: Connect to glasses device
    // 2. Check device status (optional heartbeat)
    // 3. Request WiFi Transfer: openWifiWithMode:QCOperatorDeviceModeTransfer
    // 4. Receive Credentials: Get SSID and password from glasses
    // 5. Check device status (optional heartbeat)
    // 6. Wait for Hotspot Ready: getDeviceWifiIPSuccess with retry logic
    // 7. Get Device IP: Receive IP address when hotspot is broadcasting
    // 8. Check device status (optional heartbeat)
    // 9. Configure iOS WiFi: Apply NEHotspotConfiguration with received credentials
    // 10. Check device status: getDeviceConfigWithFinished (CRITICAL VERIFICATION STEP)
    // 11. Wait for Connection: 5-second delay for iOS to establish connection
    // 12. Test Connection: HTTP request to device IP
    // 13. Start Transfer: Begin media download
    //
    // KEY INSIGHTS:
    // - Bluetooth synchronization is CRITICAL - never skip getDeviceWifiIPSuccess
    // - Device status checks catch state inconsistencies before they cause failures
    // - iOS needs time to join WiFi after NEHotspotConfiguration (5+ seconds)
    // - Always test actual connectivity, not just WiFi association status
    // - If any step fails, show manual instructions as fallback

    // STEP 3: Request WiFi Transfer - Enable WiFi transfer mode via Bluetooth
    [QCSDKCmdCreator openWifiWithMode:QCOperatorDeviceModeTransfer success:^(NSString *ssid, NSString *password) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        strongSelf.mediaDownloadStatus = [NSString stringWithFormat:@"Glasses hotspot ready: %@", ssid ?: @"<unknown>"];
        [strongSelf.tableView reloadData];

        NSLog(@"🔥 SUCCESS: Glasses enabled WiFi transfer mode");
        NSLog(@"📶 Hotspot SSID: %@", ssid ?: @"(none)");
        NSLog(@"🔐 Password: %@", password ?: @"(none)");

        // STEP 4: Receive Credentials - Got SSID and password successfully
        // STEP 6: Wait for Hotspot Ready - CRITICAL Bluetooth synchronization step
        // This step ensures the glasses hotspot is actually broadcasting before attempting WiFi
        NSLog(@"⏳ Waiting for glasses hotspot to be ready...");
        [self waitForGlassesHotspotReadiness:ssid password:password];

    } fail:^(NSInteger mode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        strongSelf.mediaDownloadStatus = @"Failed to enable WiFi transfer mode";
        [strongSelf.tableView reloadData];
        NSLog(@"🔥 FAILED: Could not enable WiFi transfer mode, current mode: %zd", mode);
    }];
}

- (void)waitForGlassesHotspotReadiness:(NSString *)ssid password:(NSString *)password {
    NSLog(@"⏳ Waiting for glasses hotspot to be ready...");
    self.mediaDownloadStatus = @"Waiting for glasses hotspot to activate...";
    [self.tableView reloadData];

    // Step 2: Use Bluetooth to check if device is ready for WiFi connection
    // This is the key insight: wait for Bluetooth confirmation before attempting WiFi
    [self checkGlassesHotspotReadinessWithRetry:0 ssid:ssid password:password];
}

- (void)checkGlassesHotspotReadinessWithRetry:(NSInteger)retry ssid:(NSString *)ssid password:(NSString *)password {
    const NSInteger maxRetries = 10;
    __weak typeof(self) weakSelf = self;

    NSLog(@"🔍 Checking glasses hotspot readiness (attempt %ld/%ld)...", (long)(retry + 1), (long)(maxRetries));
    self.mediaDownloadStatus = [NSString stringWithFormat:@"Checking hotspot readiness (%ld/%ld)...", (long)(retry + 1), (long)(maxRetries)];
    [self.tableView reloadData];

    // STEP 7: Get Device IP - The MOST CRITICAL synchronization point
    // getDeviceWifiIPSuccess confirms the glasses hotspot is actually broadcasting
    // This is the key insight that separates working from broken implementations
    [QCSDKCmdCreator getDeviceWifiIPSuccess:^(NSString *ipAddress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        if (ipAddress.length > 0) {
            // STEP 7 SUCCESS: Got actual device IP - hotspot is confirmed broadcasting
            NSLog(@"🎉 SUCCESS: Glasses hotspot is ready and broadcasting at %@", ipAddress);
            strongSelf.mediaDownloadStatus = @"Hotspot confirmed! Configuring WiFi...";
            [strongSelf.tableView reloadData];

            // STEP 9: Configure iOS WiFi - Apply NEHotspotConfiguration now that we know hotspot is ready
            // IMPORTANT: Only configure WiFi AFTER getDeviceWifiIPSuccess succeeds
            [strongSelf configureWiFiConnection:ssid password:password deviceIP:ipAddress];

        } else {
            // Continue checking if we have retries left
            if (retry < maxRetries - 1) {
                NSLog(@"🔄 Retrying hotspot readiness check...");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf checkGlassesHotspotReadinessWithRetry:retry + 1 ssid:ssid password:password];
                });
            } else {
                NSLog(@"❌ Glasses hotspot not ready after maximum retries");
                strongSelf.mediaDownloadStatus = @"Hotspot activation failed. Please try again.";
                [strongSelf.tableView reloadData];

                // Show manual instructions as fallback
                [strongSelf showManualWiFiInstructions:ssid password:password];
            }
        }

    } failed:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        NSLog(@"❌ Failed to get WiFi IP from glasses");

        // Continue checking if we have retries left
        if (retry < maxRetries - 1) {
            NSLog(@"🔄 Retrying IP request...");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf checkGlassesHotspotReadinessWithRetry:retry + 1 ssid:ssid password:password];
            });
        } else {
            NSLog(@"❌ Could not get glasses WiFi IP after maximum retries");
            strongSelf.mediaDownloadStatus = @"Failed to detect glasses hotspot";
            [strongSelf.tableView reloadData];

            // Show manual instructions as fallback
            [strongSelf showManualWiFiInstructions:ssid password:password];
        }
    }];
}

- (void)configureWiFiConnection:(NSString *)ssid password:(NSString *)password deviceIP:(NSString *)deviceIP {
    NSLog(@"📱 Configuring WiFi connection to hotspot: %@", ssid);
    NSLog(@"🔑 Password length: %lu", (unsigned long)password.length);

    if (@available(iOS 11.0, *)) {
        NSLog(@"✅ iOS 11+ detected, proceeding with NEHotspotConfiguration");
        NEHotspotConfiguration *configuration = nil;

        if (password.length > 0) {
            configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssid
                                                               passphrase:password
                                                                   isWEP:NO];
        } else {
            configuration = [[NEHotspotConfiguration alloc] initWithSSID:ssid];
        }

        // Single-use configuration - let iOS handle the rest
        configuration.joinOnce = YES;
        if (@available(iOS 13.0, *)) {
            configuration.lifeTimeInDays = @1;
        }

        self.mediaDownloadStatus = [NSString stringWithFormat:@"Joining %@ via iOS...", ssid];
        [self.tableView reloadData];

        __weak typeof(self) weakSelf = self;
        NSLog(@"🔧 Applying NEHotspotConfiguration...");
        NSLog(@"📶 SSID: %@", ssid);
        NSLog(@"🔑 Password: %@", password.length > 0 ? @"[REDACTED]" : @"[NONE]");
        NSLog(@"🔧 joinOnce: YES");

        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration
                                                     completionHandler:^(NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }

            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    // STEP 9 SUCCESS: NEHotspotConfiguration applied successfully
                    // NOTE: This only means iOS accepted the configuration, NOT that connection is established
                    NSLog(@"✅ WiFi configuration applied successfully");
                    strongSelf.mediaDownloadStatus = @"WiFi configured! Verifying device status...";
                    [strongSelf.tableView reloadData];

                    // Store connection parameters for later steps
                    strongSelf.glassesDeviceIP = deviceIP;
                    strongSelf.glassesSSID = ssid;
                    strongSelf.glassesPassword = password;

                    // STEP 10: Check device status - CRITICAL VERIFICATION STEP
                    // This ensures the glasses device is still in the expected state after WiFi configuration
                    // Catches any device state inconsistencies that could cause connection failures
                    NSLog(@"🔍 Checking device status after WiFi configuration...");
                    [strongSelf.tableView reloadData];

                    [QCSDKCmdCreator getDeviceConfigWithFinished:^(BOOL success, NSError * _Nullable configError, id _Nullable configData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                // STEP 10 SUCCESS: Device status check passed - glasses are in expected state
                                NSLog(@"✅ Device status check passed - device is ready");
                                NSLog(@"📊 Config data: %@", configData ?: @"(no data)");
                                strongSelf.mediaDownloadStatus = @"Device verified! Testing connection...";
                                [strongSelf.tableView reloadData];

                                // STEP 11: Wait for Connection - Give iOS time to establish WiFi connection
                                // iOS needs time to actually join the network after NEHotspotConfiguration
                                // 5 seconds is based on working implementation timing
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    // STEP 12: Test Connection - Verify actual network connectivity to device
                                    NSLog(@"🔗 Testing connection after 5-second delay...");
                                    [strongSelf testConnectionToDevice:deviceIP];
                                });

                            } else {
                                NSLog(@"❌ Device status check failed: %@", configError.localizedDescription);
                                strongSelf.mediaDownloadStatus = [NSString stringWithFormat:@"Device error: %@", configError.localizedDescription];
                                [strongSelf.tableView reloadData];

                                // Device is not in expected state - show manual instructions
                                [strongSelf showManualWiFiInstructions:ssid password:password];
                            }
                        });
                    }];

                } else if (error.code == NEHotspotConfigurationErrorAlreadyAssociated) {
                    NSLog(@"✅ Already associated with hotspot");
                    strongSelf.mediaDownloadStatus = @"Already connected! Testing...";
                    [strongSelf.tableView reloadData];

                    // Store the target IP and test immediately
                    strongSelf.glassesDeviceIP = deviceIP;
                    strongSelf.glassesSSID = ssid;
                    strongSelf.glassesPassword = password;

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf testConnectionToDevice:deviceIP];
                    });

                } else {
                    NSLog(@"❌ WiFi configuration failed: %@", error.localizedDescription);
                    NSLog(@"❌ Error code: %ld", (long)error.code);
                    NSLog(@"❌ Error domain: %@", error.domain);
                    strongSelf.mediaDownloadStatus = [NSString stringWithFormat:@"Auto WiFi failed: %@", error.localizedDescription];
                    [strongSelf.tableView reloadData];

                            // Show manual connection instructions as fallback
                    [strongSelf showManualWiFiInstructions:ssid password:password];
                }
            });
        }];
    }
}

- (void)testConnectionWithCommonIPs {
    NSLog(@"🔗 Testing connection to common glasses IP addresses...");
    self.mediaDownloadStatus = @"Testing connection to glasses...";
    [self.tableView reloadData];

    // If we have the actual device IP from Bluetooth, use it
    if (self.glassesDeviceIP && self.glassesDeviceIP.length > 0) {
        [self testConnectionToDevice:self.glassesDeviceIP];
        return;
    }

    // Common glasses IPs to test
    NSArray *possibleIPs = @[
        @"192.168.43.1", @"192.168.4.1", @"192.168.31.1", @"192.168.1.1",
        @"192.168.0.1", @"192.168.100.1", @"192.168.123.1", @"192.168.137.1",
        @"10.0.0.1", @"172.20.10.1"
    ];

    [self testIPs:possibleIPs index:0];
}

- (void)testConnectionToDevice:(NSString *)deviceIP {
    // STEP 12: Test Connection - Verify actual network connectivity to glasses device
    // This tests the complete end-to-end connection: Bluetooth → WiFi Configuration → Network Path
    NSLog(@"🔗 Testing connection to specific device IP: %@", deviceIP);
    self.mediaDownloadStatus = [NSString stringWithFormat:@"Testing connection to %@...", deviceIP];
    [self.tableView reloadData];

    // Test the known glasses endpoint for connectivity verification
    NSString *testURL = [NSString stringWithFormat:@"http://%@/files/media.config", deviceIP];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:testURL]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  // Fresh request, no cache
                                        timeoutInterval:10.0];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && data && ((NSHTTPURLResponse *)response).statusCode == 200) {
                // STEP 12 SUCCESS: End-to-end connectivity confirmed
                // STEP 13: Start Transfer - Begin media download from glasses
                NSLog(@"🎉 SUCCESS: Connected to glasses at %@", deviceIP);
                self.mediaDownloadStatus = [NSString stringWithFormat:@"✅ Connected to %@! Starting download...", deviceIP];
                [self.tableView reloadData];

                // Start media download immediately
                [self startMediaDownloadFromDevice:deviceIP];

            } else {
                NSLog(@"❌ Connection test failed: %@", error.localizedDescription);
                self.mediaDownloadStatus = @"Connection failed. Trying common IPs...";
                [self.tableView reloadData];

                // Fall back to trying common IP addresses (like working implementation)
                NSArray *possibleIPs = @[
                    @"192.168.43.1", @"192.168.4.1", @"192.168.31.1", @"192.168.1.1",
                    @"192.168.0.1", @"192.168.100.1", @"192.168.123.1", @"192.168.137.1",
                    @"10.0.0.1", @"172.20.10.1"
                ];
                [self testIPs:possibleIPs index:0];
            }
        });
    }];

    [task resume];
}

- (void)testIPs:(NSArray *)ips index:(NSInteger)index {
    if (index >= ips.count) {
        self.mediaDownloadStatus = @"Could not find glasses on any known IP address";
        [self.tableView reloadData];
        return;
    }

    NSString *currentIP = ips[index];
    NSString *testURL = [NSString stringWithFormat:@"http://%@/files/media.config", currentIP];

    self.mediaDownloadStatus = [NSString stringWithFormat:@"Testing %@ (%ld/%lu)...", currentIP, (long)index + 1, (unsigned long)ips.count];
    [self.tableView reloadData];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:testURL]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:3.0];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && ((NSHTTPURLResponse *)response).statusCode == 200) {
                self.mediaDownloadStatus = [NSString stringWithFormat:@"✅ Connected to glasses at %@", currentIP];
                [self.tableView reloadData];
                NSLog(@"🎉 SUCCESS: Connected to glasses at %@", currentIP);

                // Start media download
                [self startMediaDownloadFromDevice:currentIP];

            } else {
                // Try next IP
                [self testIPs:ips index:index + 1];
            }
        });
    }] resume];
}

- (void)startMediaDownloadFromDevice:(NSString *)deviceIP {
    NSLog(@"📥 Starting media download from device at %@", deviceIP);
    self.mediaDownloadStatus = @"Starting media download...";
    [self.tableView reloadData];

    // Initialize media downloader with the device IP
    __weak typeof(self) weakSelf = self;
    self.mediaDownloader = [[GlassesMediaDownloader alloc] initWithStatusHandler:^(NSString *status, UIImage * _Nullable previewImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mediaDownloadStatus = status;
            if (previewImage) {
                weakSelf.latestDownloadedMediaPreview = previewImage;
            }
            [weakSelf.tableView reloadData];
        });
    }];

    [self.mediaDownloader startDownloadWithCompletion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.mediaDownloadStatus = [NSString stringWithFormat:@"Download failed: %@", error.localizedDescription ?: @"Unknown error"];
            } else {
                weakSelf.mediaDownloadStatus = @"Download complete!";
            }
            weakSelf.mediaDownloader = nil;
            [weakSelf.tableView reloadData];
        });
    }];
}


- (void)showManualWiFiInstructions:(NSString *)ssid password:(NSString *)password {
    NSLog(@"📖 Showing manual WiFi connection instructions");

    NSString *message = [NSString stringWithFormat:@"Manual WiFi Connection Required\n\n"
                          @"Please join the network manually:\n\n"
                          @"Network Name (SSID): %@\n"
                          @"Password: %@\n\n"
                          @"Steps:\n"
                          @"1. Open Settings → Wi-Fi\n"
                          @"2. Select '%@'\n"
                          @"3. Enter password when prompted\n"
                          @"4. Return to app when connected\n\n"
                          @"The app will automatically detect when you're connected.",
                          ssid ?: @"(unknown)", password ?: @"123456789", ssid ?: @"(unknown)"];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Manual WiFi Connection"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:okAction];

    // For iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0);
    }

    [self presentViewController:alert animated:YES completion:nil];
}


@end
