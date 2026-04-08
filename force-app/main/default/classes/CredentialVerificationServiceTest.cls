@isTest
private class CredentialVerificationServiceTest {

    @isTest
    static void testValid() {
        Contact con = new Contact(
            FirstName = 'Omar',
            LastName = 'Muller'
        );
        insert con;

        Certification__c cert = new Certification__c(
            Name = 'Drone License A'
        );
        insert cert;

        Contact_Certification__c cc = new Contact_Certification__c(
            Contact__c = con.Id,
            Certification__c = cert.Id,
            Issue_Date__c = Date.today(),
            isActive__c = true
        );
        insert cc;

        cc = [
            SELECT Id, Name
            FROM Contact_Certification__c
            WHERE Id = :cc.Id
            LIMIT 1
        ];

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Muller', cc.Name);
        Test.stopTest();

        System.assertEquals('Valid', result);
    }

    @isTest
    static void testNeedsRenewal() {
        Contact con = new Contact(
            FirstName = 'Ali',
            LastName = 'Schmidt'
        );
        insert con;

        Certification__c cert = new Certification__c(
            Name = 'Drone License B'
        );
        insert cert;

        Contact_Certification__c cc = new Contact_Certification__c(
            Contact__c = con.Id,
            Certification__c = cert.Id,
            Issue_Date__c = Date.today(),
            isActive__c = false
        );
        insert cc;

        cc = [
            SELECT Id, Name
            FROM Contact_Certification__c
            WHERE Id = :cc.Id
            LIMIT 1
        ];

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('Schmidt', cc.Name);
        Test.stopTest();

        System.assertEquals('Needs Renewal', result);
    }

    @isTest
    static void testNoRecordFound() {
        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('WrongName', 'WrongCert');
        Test.stopTest();

        System.assertEquals('No record found', result);
    }

    @isTest
    static void testBlankInput() {
        Test.startTest();
        String result1 = CredentialVerificationService.verifyCredential('', 'Anything');
        String result2 = CredentialVerificationService.verifyCredential('Test', '');
        String result3 = CredentialVerificationService.verifyCredential(null, null);
        Test.stopTest();

        System.assertEquals('No record found', result1);
        System.assertEquals('No record found', result2);
        System.assertEquals('No record found', result3);
    }
}