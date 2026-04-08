@RestResource(urlMapping='/verifyCredential/*')
global with sharing class BYDVerificationRestService {

    @HttpGet
    global static String verify() {

        RestRequest req = RestContext.request;

        String lastName = req.params.get('lastName');
        String certName = req.params.get('certName');

        return BYDVerificationService.verify(lastName, certName);
    }
}