public with sharing class AuthorController {
    @AuraEnabled
    public static Id addAuthor(String name, String surname, String description, String region) {
        if (String.isBlank(name)) {
            throw new AuraHandledException('Missing required field: Author Name.');
        }

        if (!String.isBlank(description) && description.length() > 3000) {
            throw new AuraHandledException('Description should not exceed 3000 characters.');
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
            throw new AuraHandledException('Error creating new author: ' + e.getMessage());
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
