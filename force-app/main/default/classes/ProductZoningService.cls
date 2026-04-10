@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {

    @HttpGet
    global static String getPermissibleFlyZone() {
        RestRequest req = RestContext.request;

        String productCode = req.params.get('ProductCode');

        if (String.isBlank(productCode) && req != null && req.requestURI != null) {
            Integer lastSlash = req.requestURI.lastIndexOf('/');
            if (lastSlash >= 0 && lastSlash < req.requestURI.length() - 1) {
                productCode = req.requestURI.substring(lastSlash + 1);
            }
        }

        productCode = String.isBlank(productCode) ? null : productCode.trim();

        if (String.isBlank(productCode)) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        String countryCode = req.headers.get('CountryCode');
        if (String.isBlank(countryCode)) {
            countryCode = 'US';
        } else {
            countryCode = countryCode.trim().toUpperCase();
        }

        List<Product2> products = [
            SELECT Family
            FROM Product2
            WHERE ProductCode = :productCode
            LIMIT 1
        ];

        if (products.isEmpty()) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        String productFamily = products[0].Family;

        List<Product_Geo_Mapping__mdt> mappings = [
            SELECT Permissible_Fly_Zone__c
            FROM Product_Geo_Mapping__mdt
            WHERE Product_Family__c = :productFamily
            AND Country_Code__c = :countryCode
            LIMIT 1
        ];

        if (!mappings.isEmpty() && !String.isBlank(mappings[0].Permissible_Fly_Zone__c)) {
            return mappings[0].Permissible_Fly_Zone__c + ' zones only';
        }

        return 'Confirm with the local authorities';
    }
}