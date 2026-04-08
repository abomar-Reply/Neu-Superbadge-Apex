global class CredentialVerificationService {

    webservice static String verifyCredential(String lastName, String certificationName) {

        if (String.isBlank(lastName) || String.isBlank(certificationName)) {
            return 'No record found';
        }

        List<Contact_Certification__c> certList = [
            SELECT Id, Name, isActive__c, Contact__r.LastName
            FROM Contact_Certification__c
            WHERE Contact__r.LastName = :lastName
            AND Name = :certificationName
            LIMIT 1
        ];

        if (certList.isEmpty()) {
            return 'No record found';
        }

        if (certList[0].isActive__c) {
            return 'Valid';
        }

        return 'Needs Renewal';
    }
}