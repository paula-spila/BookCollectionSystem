public with sharing class AuthorController {
    @AuraEnabled
    public static Id addAuthor(String name, String surname, String description, String region) {
        if (String.isBlank(name)) {
            throw new AuraHandledException('Trūkst obligātais lauks: Autora vārds.');
        }

        if (!String.isBlank(description) && description.length() > 5000) {
            throw new AuraHandledException('Apraksts nedrīkst pārsniegt 5000 rakstzīmes.');
        }

        Author__c newAuthor = new Author__c(
            Name = name,
            Surname__c = surname,
            Description__c = description,
            Region__c = region
        );

        try {
            insert newAuthor;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('Kļūda, izveidojot jaunu autoru: ' + e.getMessage());
        }
        
        return newAuthor.Id;
    }

    @AuraEnabled
    public static List<Map<String, String>> getRegionOptions() {
        Schema.DescribeFieldResult fieldResult = Author__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<Map<String, String>> regions = new List<Map<String, String>>();

        for (Schema.PicklistEntry entry : picklistValues) {
            Map<String, String> region = new Map<String, String>();
            region.put('label', entry.getLabel());
            region.put('value', entry.getValue());
            regions.add(region);
        }

        return regions;
    }
}
