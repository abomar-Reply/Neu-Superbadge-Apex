@IsTest
private class AssetServiceTest {

    @IsTest
    static void testNoDeviceFound() {
        Test.startTest();
        String result = AssetService.reportLostDevice('NOTFOUND123');
        Test.stopTest();

        System.assertEquals('No device found.', result);
    }

    @IsTest
    static void testNoCoverage() {
        Account acc = new Account(Name='Test Acc 1');
        insert acc;

        Contact con = new Contact(LastName='Test Contact 1', AccountId=acc.Id);
        insert con;

        Asset a = new Asset(
            Name='Asset 1',
            AccountId=acc.Id,
            ContactId=con.Id,
            Asset_Identifier__c='ASSET001',
            Status='Installed'
        );
        insert a;

        Test.startTest();
        String result = AssetService.reportLostDevice('ASSET001');
        Test.stopTest();

        Asset updatedAsset = [SELECT Status FROM Asset WHERE Id = :a.Id];
        System.assertEquals('Lost', updatedAsset.Status);
        System.assertEquals('No coverage. Asset status adjusted to Lost.', result);
    }

    @IsTest
    static void testCreateClaim() {
        Account acc = new Account(Name='Test Acc 2');
        insert acc;

        Contact con = new Contact(LastName='Test Contact 2', AccountId=acc.Id);
        insert con;

        Asset a = new Asset(
            Name='Asset 2',
            AccountId=acc.Id,
            ContactId=con.Id,
            Asset_Identifier__c='ASSET002',
            Status='Installed'
        );
        insert a;

        Insurance__c ins = new Insurance__c(
            Asset__c=a.Id,
            Active__c=true,
            Coverage__c='Comprehensive'
        );
        insert ins;

        Test.startTest();
        String result = AssetService.reportLostDevice('ASSET002');
        Test.stopTest();

        List<Claim__c> claims = [
            SELECT Id, Name, Type__c, Insurance__c
            FROM Claim__c
            WHERE Insurance__c = :ins.Id
        ];

        System.assertEquals(1, claims.size());
        System.assertEquals('Loss', claims[0].Type__c);
        System.assertEquals(claims[0].Name, result);
    }

    @IsTest
    static void testAlreadyFiled() {
        Account acc = new Account(Name='Test Acc 3');
        insert acc;

        Contact con = new Contact(LastName='Test Contact 3', AccountId=acc.Id);
        insert con;

        Asset a = new Asset(
            Name='Asset 3',
            AccountId=acc.Id,
            ContactId=con.Id,
            Asset_Identifier__c='ASSET003',
            Status='Installed'
        );
        insert a;

        Insurance__c ins = new Insurance__c(
            Asset__c=a.Id,
            Active__c=true,
            Coverage__c='Comprehensive'
        );
        insert ins;

        Claim__c existingClaim = new Claim__c(
            Status__c='New',
            Type__c='Loss',
            Asset__c=a.Id,
            Contact__c=con.Id,
            Insurance__c=ins.Id
        );
        insert existingClaim;

        existingClaim = [SELECT Id, Name FROM Claim__c WHERE Id = :existingClaim.Id LIMIT 1];

        Test.startTest();
        String result = AssetService.reportLostDevice('ASSET003');
        Test.stopTest();

        System.assertEquals(existingClaim.Name + ' already filed', result);
    }
}