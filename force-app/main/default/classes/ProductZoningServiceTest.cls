@IsTest(SeeAllData=true)
private class ProductZoningServiceTest {

    @IsTest
    static void testMissingProductCode() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('ProductCode is missing or doesn\'t exist', result);
    }

    @IsTest
    static void testInvalidProductCode() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.addParameter('ProductCode', 'INVALIDCODE');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('ProductCode is missing or doesn\'t exist', result);
    }

    @IsTest
    static void testWithoutCountryCode() {
        Product2 p = [
            SELECT ProductCode, Family
            FROM Product2
            WHERE ProductCode != null AND Family != null
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.addParameter('ProductCode', p.ProductCode);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = ProductZoningService.getPermissibleFlyZone();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testWithCountryCode() {
        Product2 p = [
            SELECT ProductCode, Family
            FROM Product2
            WHERE ProductCode != null AND Family != null
            LIMIT 1
        ];

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.addParameter('ProductCode', p.ProductCode);
        req.addHeader('CountryCode', 'DE');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String result = ProductZoningService.getPermissibleFlyZone();
        System.assertNotEquals(null, result);
    }
}