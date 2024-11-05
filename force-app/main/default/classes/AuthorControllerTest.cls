@isTest
private class AuthorControllerTest {
    
    @isTest
    static void testAddAuthorSuccess() {
        Test.startTest();
        Id authorId = AuthorController.addAuthor('John', 'Doe', 'A brief description', 'North America');
        Test.stopTest();
        
        Author__c addededAuthor = [SELECT Id, Name, Surname__c, Description__c, Region__c FROM Author__c WHERE Id = :authorId];
        System.assertNotEquals(null, addededAuthor, 'Author should be added successfully.');
        System.assertEquals('John', addededAuthor.Name, 'Author name should match.');
        System.assertEquals('Doe', addededAuthor.Surname__c, 'Author surname should match.');
        System.assertEquals('A brief description', addededAuthor.Description__c, 'Description should match.');
        System.assertEquals('North America', addededAuthor.Region__c, 'Region should match.');
    }

    @isTest
    static void testAddAuthorMissingName() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            AuthorController.addAuthor('', 'Doe', 'Description', 'North America');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for missing the Author Name.');
    }

    @isTest
    static void testAddAuthorLongDescription() {
        Boolean exceptionThrown = false;
        String longDescription = String.join(new List<String>(3006), 'a');
        Test.startTest();
        try {
            AuthorController.addAuthor('John', 'Doe', longDescription, 'North America');
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
