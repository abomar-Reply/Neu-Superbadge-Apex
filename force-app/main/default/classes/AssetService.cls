@RestResource(urlMapping='/lost/*')
global without sharing class AssetService {

    global class LostDeviceRequest {
        public String assetIdentifier;
    }

    @HttpPost
    global static String reportLostDevice() {
        String body = RestContext.request.requestBody.toString();
        LostDeviceRequest reqObj = (LostDeviceRequest) JSON.deserialize(body, LostDeviceRequest.class);
        return reportLostDevice(reqObj.assetIdentifier);
    }

    global static String reportLostDevice(String assetIdentifier) {
        if (String.isBlank(assetIdentifier)) {
            return 'No device found.';
        }

        List<Asset> assets = [
            SELECT Id, ContactId, Status, Asset_Identifier__c
            FROM Asset
            WHERE Asset_Identifier__c = :assetIdentifier
            LIMIT 1
        ];

        if (assets.isEmpty()) {
            return 'No device found.';
        }

        Asset a = assets[0];
        a.Status = 'Lost';
        update a;

        List<Insurance__c> insList = [
            SELECT Id, Asset__c, Active__c, Coverage__c
            FROM Insurance__c
            WHERE Asset__c = :a.Id
            AND Active__c = true
            AND Coverage__c = 'Comprehensive'
            LIMIT 1
        ];

        if (insList.isEmpty()) {
            return 'No coverage. Asset status adjusted to Lost.';
        }

        Insurance__c ins = insList[0];

        List<Claim__c> oldClaims = [
            SELECT Id, Name
            FROM Claim__c
            WHERE Insurance__c = :ins.Id
            AND Type__c = 'Loss'
            LIMIT 1
        ];

        if (!oldClaims.isEmpty()) {
            return oldClaims[0].Name + ' already filed';
        }

        Claim__c c = new Claim__c();
        c.Status__c = getClaimStatusValue();
        c.Type__c = 'Loss';
        c.Asset__c = a.Id;
        c.Contact__c = a.ContactId;
        c.Insurance__c = ins.Id;
        insert c;

        c = [SELECT Id, Name FROM Claim__c WHERE Id = :c.Id LIMIT 1];
        return c.Name;
    }

    global static String getClaimStatusValue() {
        return 'New';
    }
}