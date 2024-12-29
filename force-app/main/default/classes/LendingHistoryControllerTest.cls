@IsTest
public class LendingHistoryControllerTest {
    static BookInUserCollection__c setupTestData() {
        BookInUserCollection__c bookCollection = new BookInUserCollection__c();
        insert bookCollection;

        Lending_History__c lendingHistory = new Lending_History__c(
            BookInUserCollection__c = bookCollection.Id,
            Lender_name__c = 'John Doe',
            Lending_date__c = Date.today().addDays(-10),
            Return_status__c = 'Not Returned'
        );
        insert lendingHistory;

        return bookCollection;
    }

    @IsTest
    static void testGetLendingHistorySuccess() {
        BookInUserCollection__c bookCollection = setupTestData();

        Test.startTest();
        List<Lending_History__c> lendingHistory = LendingHistoryController.getLendingHistory(bookCollection.Id);
        Test.stopTest();

        System.assertNotEquals(null, lendingHistory, 'Lending history should not be null.');
        System.assertEquals(1, lendingHistory.size(), 'There should be one lending record.');
        System.assertEquals('John Doe', lendingHistory[0].Lender_name__c, 'Lender name should match.');
    }

    @IsTest
    static void testGetLendingHistoryMissingBookCollectionId() {
        Boolean didThrowExpectedException = false;

        Test.startTest();
        try {
            LendingHistoryController.getLendingHistory(null);
        } catch (AuraHandledException ex) {
            didThrowExpectedException = true;
        }
        Test.stopTest();

        System.assert(didThrowExpectedException, 'Expected an exception to be thrown for missing book collection ID.');
    }

    @IsTest
    static void testCreateLendingSuccess() {
        BookInUserCollection__c bookCollection = setupTestData();

        Test.startTest();
        LendingHistoryController.createLending(
            bookCollection.Id,
            'Jane Doe',
            Date.today(),
            'Not returned'
        );
        Test.stopTest();

        Lending_History__c createdLending = [SELECT Id, Lender_name__c, Lending_date__c, Return_status__c
                                             FROM Lending_History__c
                                             WHERE Lender_name__c = 'Jane Doe' LIMIT 1];
        System.assertNotEquals(null, createdLending, 'Lending record should have been created.');
        System.assertEquals('Jane Doe', createdLending.Lender_name__c, 'Lender name should match.');
        System.assertEquals(Date.today(), createdLending.Lending_date__c, 'Lending date should match.');
        System.assertEquals('Not returned', createdLending.Return_status__c, 'Return status should match.');
    }

    @IsTest
    static void testCreateLendingMissingFields() {
        Boolean didThrowExpectedException = false;

        Test.startTest();
        try {
            LendingHistoryController.createLending(null, null, null, null);
        } catch (AuraHandledException ex) {
            didThrowExpectedException = true;
        }
        Test.stopTest();

        System.assert(didThrowExpectedException, 'Expected an exception to be thrown for missing required fields.');
    }

    @IsTest
    static void testMarkAsReturnedSuccess() {
        BookInUserCollection__c bookCollection = setupTestData();
        Lending_History__c lendingRecord = [SELECT Id FROM Lending_History__c LIMIT 1];

        Test.startTest();
        LendingHistoryController.markAsReturned(lendingRecord.Id);
        Test.stopTest();

        Lending_History__c updatedLending = [SELECT Id, Return_status__c, Return_date__c FROM Lending_History__c WHERE Id = :lendingRecord.Id];
        System.assertEquals('Returned', updatedLending.Return_status__c, 'Return status should be updated to "Returned".');
        System.assertEquals(Date.today(), updatedLending.Return_date__c, 'Return date should be updated to today.');
    }

    @IsTest
    static void testMarkAsReturnedMissingLendingId() {
        Boolean didThrowExpectedException = false;

        Test.startTest();
        try {
            LendingHistoryController.markAsReturned(null);
        } catch (AuraHandledException ex) {
            didThrowExpectedException = true;
        }
        Test.stopTest();

        System.assert(didThrowExpectedException, 'Expected an exception to be thrown for missing lending record ID.');
    }
}
