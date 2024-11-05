@isTest
private class AuthorControllerTest {
    
    @isTest
    static void testCreateAuthorSuccess() {
        Test.startTest();
        Id authorId = AuthorController.createAuthor('John', 'Doe', 'A brief description', 'North America');
        Test.stopTest();
        
        Author__c createdAuthor = [SELECT Id, Name, Surname__c, Description__c, Region__c FROM Author__c WHERE Id = :authorId];
        System.assertNotEquals(null, createdAuthor, 'Author should be created successfully.');
        System.assertEquals('John', createdAuthor.Name, 'Author name should match.');
        System.assertEquals('Doe', createdAuthor.Surname__c, 'Author surname should match.');
        System.assertEquals('A brief description', createdAuthor.Description__c, 'Description should match.');
        System.assertEquals('North America', createdAuthor.Region__c, 'Region should match.');
    }

    @isTest
    static void testCreateAuthorMissingName() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            AuthorController.createAuthor('', 'Doe', 'Description', 'North America');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for missing the Author Name.');
    }

    @isTest
    static void testCreateAuthorLongDescription() {
        Boolean exceptionThrown = false;
        String longDescription = String.join(new List<String>(3006), 'a');
        Test.startTest();
        try {
            AuthorController.createAuthor('John', 'Doe', longDescription, 'North America');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for an excessive description length.');
    }
    
    @isTest
    static void testGetRegionOptions() {
        List<Map<String, String>> regionOptions = AuthorController.getRegionOptions();
        System.assertNotEquals(0, regionOptions.size(), 'Region options should not be empty.');
        
        for (Map<String, String> region : regionOptions) {
            System.assert(region.containsKey('label'), 'Each region should have a label.');
            System.assert(region.containsKey('value'), 'Each region should have a value.');
        }
    }
}