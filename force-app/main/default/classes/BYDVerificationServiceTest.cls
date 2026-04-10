@isTest
private class BYDVerificationServiceTest {

    @isTest
    static void testValid() {
        Contact con = new Contact(
            LastName = 'Wei'
        );
        insert con;

        Certification__c cert = new Certification__c(
            Name = 'Drone License A Test'
        );
        insert cert;

        Contact_Certification__c cc = new Contact_Certification__c(
            Contact__c = con.Id,
            Certification__c = cert.Id,
            Issue_Date__c = Date.today(),
            isActive__c = true
        );
        insert cc;

        String result = BYDVerificationService.verify('Wei', 'Drone License A Test');
        System.assertEquals('Valid', result);
    }

    @isTest
    static void testNeedsRenewal() {
        Contact con = new Contact(
            LastName = 'Ali'
        );
        insert con;

        Certification__c cert = new Certification__c(
            Name = 'Drone License B Test'
        );
        insert cert;

        Contact_Certification__c cc = new Contact_Certification__c(
            Contact__c = con.Id,
            Certification__c = cert.Id,
            Issue_Date__c = Date.today(),
            isActive__c = false
        );
        insert cc;

        String result = BYDVerificationService.verify('Ali', 'Drone License B Test');
        System.assertEquals('Needs Renewal', result);
    }

    @isTest
    static void testNoMatch() {
        String result = BYDVerificationService.verify('NotFound', 'Unknown Cert');
        System.assertEquals('No matching record found', result);
    }
}