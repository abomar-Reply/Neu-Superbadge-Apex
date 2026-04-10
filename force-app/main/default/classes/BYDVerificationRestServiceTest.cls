@isTest
private class BYDVerificationRestServiceTest {

    @isTest
    static void testRestValid() {
        Contact con = new Contact(
            LastName = 'Wei'
        );
        insert con;

        Certification__c cert = new Certification__c(
            Name = 'Drone License REST Test'
        );
        insert cert;

        Contact_Certification__c cc = new Contact_Certification__c(
            Contact__c = con.Id,
            Certification__c = cert.Id,
            Issue_Date__c = Date.today(),
            isActive__c = true
        );
        insert cc;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/verifyCredential';
        req.httpMethod = 'GET';
        req.addParameter('lastName', 'Wei');
        req.addParameter('certName', 'Drone License REST Test');

        RestContext.request = req;
        RestContext.response = res;

        String result = BYDVerificationRestService.verify();

        System.assertEquals('Valid', result);
    }

    @isTest
    static void testRestNoMatch() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/verifyCredential';
        req.httpMethod = 'GET';
        req.addParameter('lastName', 'Unknown');
        req.addParameter('certName', 'Unknown Cert');

        RestContext.request = req;
        RestContext.response = res;

        String result = BYDVerificationRestService.verify();

        System.assertEquals('No matching record found', result);
    }
}