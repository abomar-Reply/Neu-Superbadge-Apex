global class BYDVerificationService {

    webservice static String verify(String contactLastName, String certificationName) {

        List<Contact_Certification__c> certList = [
            SELECT Id,
                   Issue_Date__c,
                   isActive__c,
                   Contact__r.LastName,
                   Certification__r.Name
            FROM Contact_Certification__c
            WHERE Contact__r.LastName = :contactLastName
            AND Certification__r.Name = :certificationName
            LIMIT 1
        ];

        if (certList.isEmpty()) {
            return 'No matching record found';
        }

        Contact_Certification__c cert = certList[0];

        if (cert.isActive__c == true) {
            return 'Valid';
        } else {
            return 'Needs Renewal';
        }
    }
}