@IsTest
public class LendingHistoryControllerTest {
    @IsTest
    static void testCreateLendingSuccess() {
        Book__c book = new Book__c(Name = 'Test Book');
        insert book;

        Date lendingDate = Date.today().addDays(-1);
        Date returnDate = Date.today();
        
        Test.startTest();
        Id lendingId = LendingHistoryController.createLending(book.Id, 'Test Lending History', lendingDate, returnDate, 'Returned');
        Test.stopTest();
        
        Lending_History__c lending = [SELECT Id, Name, Lending_date__c, Return_date__c, Return_status__c FROM Lending_History__c WHERE Id = :lendingId];
        System.assertEquals('Test Lending History', lending.Name);
        System.assertEquals(lendingDate, lending.Lending_date__c);
        System.assertEquals(returnDate, lending.Return_date__c);
        System.assertEquals('Returned', lending.Return_status__c);
    }

    @IsTest
    static void testCreateLendingMissingFields() {
        Boolean didThrowExpectedException = false;
        
        try {
            Test.startTest();
            LendingHistoryController.createLending(null, null, Date.today(), Date.today().addDays(1), 'Returned');
            Test.stopTest();
        } catch (Exception e) {
            didThrowExpectedException = true;
        }
        
        System.assert(didThrowExpectedException, 'Expected an exception but none was thrown.');
    }

    @IsTest
    static void testCreateLendingFutureLendingDate() {
        Book__c book = new Book__c(Name = 'Test Book');
        insert book;
        
        Boolean didThrowExpectedException = false;
        
        try {
            Test.startTest();
            LendingHistoryController.createLending(book.Id, 'Test Lending History', Date.today().addDays(1), null, null);
            Test.stopTest();
        } catch (Exception e) {
            didThrowExpectedException = true;
        }
        
        System.assert(didThrowExpectedException, 'Expected an exception but none was thrown.');
    }

    @IsTest
    static void testCreateLendingInvalidReturnDate() {
        Book__c book = new Book__c(Name = 'Test Book');
        insert book;
        
        Boolean didThrowExpectedException = false;
        
        try {
            Test.startTest();
            LendingHistoryController.createLending(book.Id, 'Test Lending History', Date.today(), Date.today().addDays(-1), 'Returned');
            Test.stopTest();
        } catch (Exception e) {
            didThrowExpectedException = true;
        }
        
        System.assert(didThrowExpectedException, 'Expected an exception but none was thrown.');
    }

    @IsTest
    static void testCreateLendingMissingReturnStatus() {
        Book__c book = new Book__c(Name = 'Test Book');
        insert book;
        
        Boolean didThrowExpectedException = false;
        
        try {
            Test.startTest();
            LendingHistoryController.createLending(book.Id, 'Test Lending History', Date.today(), Date.today(), null);
            Test.stopTest();
        } catch (Exception e) {
            didThrowExpectedException = true;
        }
        
        System.assert(didThrowExpectedException, 'Expected an exception but none was thrown.');
    }

    @IsTest
    static void testCreateLendingLongLendingHistoryName() {
        Book__c book = new Book__c(Name = 'Test Book');
        insert book;
        
        Boolean didThrowExpectedException = false;
        
        try {
            Test.startTest();
            LendingHistoryController.createLending(book.Id, 'Lending History Name Exceeding 80 Characters Is Not Valid And Should Trigger An Exception', Date.today(), null, null);
            Test.stopTest();
        } catch (Exception e) {
            didThrowExpectedException = true;
        }
        
        System.assert(didThrowExpectedException, 'Expected an exception but none was thrown.');
    }

    @IsTest
    static void testGetReturnStatusOptions() {
        Test.startTest();
        List<Map<String, String>> options = LendingHistoryController.getReturnStatusOptions();
        Test.stopTest();
        
        System.assert(!options.isEmpty(), 'Expected return status options not to be empty.');
        for (Map<String, String> option : options) {
            System.assert(option.containsKey('label'), 'Option should contain a label.');
            System.assert(option.containsKey('value'), 'Option should contain a value.');
        }
    }
}
