//
//  stubSNs.m
//  ipumpi
//
//  Created by Dave Scruton on 5/7/21.
//  Copyright © 2021 ipumpi. All rights reserved.
//  singleton: contains stubbed serial numbers for testing

#import "stubSNs.h"

@implementation stubSNs
static stubSNs *sharedInstance = nil;

//=============(pumpTable)=====================================================
// Get the shared instance and create it if necessary.
+ (stubSNs *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

//=============(pumpTable)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        [self initSNs];
    }
    return self;
}


//======(pumpSimVC)==========================================
-(void) initSNs
{
    _snStrings = //[NSArray arrayWithArray:
    @[
        @"ipumpi_52861E86-9C67-4E24-8E44-15C29841AA1C",
        @"ipumpi_FC67E823-90D4-4266-A740-7E5F49216156",
        @"ipumpi_C1300626-CD31-4703-A138-EA0C02F63CEB",
        @"ipumpi_E0458B49-7F82-4568-9F2D-23DD19A95C0F",
        @"ipumpi_2E874F72-CE45-4E8A-9D3E-414819C67A30",
        @"ipumpi_CBAB6736-ACDE-42AB-B5B3-A7BB586CC646",
        @"ipumpi_927E32AC-F841-4663-B467-AB914E9D2EE7",
        @"ipumpi_22966CB6-71B1-407B-89F5-DED5CFC23902",
        @"ipumpi_377CF815-1176-48EE-B7C9-21373C27E237",
        @"ipumpi_FED82054-C78C-4BF4-A1E2-17B3190CD6C4",
        @"ipumpi_A07AB7AA-778E-4FA4-AE84-74F05D0F554D",
        @"ipumpi_03A0446F-003B-494B-B6B3-9D65E3AF5974",
        @"ipumpi_5EC9AA8F-1B5B-4CE9-8A0E-27A6F1A1C0B0",
        @"ipumpi_23260B36-451E-4F4D-AD32-4E9DFCE68BA8",
        @"ipumpi_0419F914-72CF-41D7-96C2-05AB4EAEA241",
        @"ipumpi_02E47420-75E8-480C-B0BD-1CBAB88119BB",
        @"ipumpi_93623F69-31FD-4FA6-A9A9-561A23AE037F",
        @"ipumpi_2F6A241D-F120-4173-B68E-4CB639A9B490",
        @"ipumpi_DA508F4D-32E1-4242-B8F5-0A316A318379",
        @"ipumpi_8B3451A2-D870-4988-A1E4-443E8F3027CA",
        @"ipumpi_1D3B12A1-8719-4601-BEED-6D4BEBE158B0",
        @"ipumpi_64CBEAE1-94B6-4C7E-A58A-664F007ED1E6",
        @"ipumpi_D2870FA0-5A18-492F-9A45-7093B089EA75",
        @"ipumpi_CCDC7E8F-AD98-4349-B754-50CB0D7E4AAC",
        @"ipumpi_325CB9BA-ADCB-40BA-BC84-3D6E411E9407",
        @"ipumpi_D265CB64-8554-4854-8B0E-E01F8AD1C19D",
        @"ipumpi_788F0CC1-4593-42BD-B2F5-0FB7F091ED32",
        @"ipumpi_F7B756E8-A680-4EF2-A43B-3B7CE5B18C59",
        @"ipumpi_E39333A0-FD28-402D-ABBD-42A1132FC898",
        @"ipumpi_D8F68E76-5EDF-4235-94B2-43A6D3EDB863",
        @"ipumpi_BF1B59B9-3581-4051-9244-085B486D972C",
        @"ipumpi_15ADD928-FBD6-4165-981D-944A339FD161"
    //    ]
    ];

}

@end
