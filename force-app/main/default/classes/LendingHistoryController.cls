public with sharing class LendingHistoryController {

    @AuraEnabled(cacheable=true)
    public static List<Lending_History__c> getLendingHistory(Id bookCollectionId) {
        if (String.isBlank(bookCollectionId)) {
            throw new AuraHandledException('The book collection ID is required.');
        }
        try {
            return [
                SELECT Id, Lender_name__c, Lending_date__c, Return_date__c, Return_status__c
                FROM Lending_History__c
                WHERE BookInUserCollection__c = :bookCollectionId
                ORDER BY Lending_date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching lending history: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createLending(Id bookCollectionId, String lenderName, Date lendingDate, String returnStatus) {
        if (String.isBlank(bookCollectionId) || String.isBlank(lenderName) || lendingDate == null) {
            throw new AuraHandledException('All required fields must be provided.');
        }

        try {
            Lending_History__c newLending = new Lending_History__c();
            newLending.BookInUserCollection__c = bookCollectionId;
            newLending.Lender_name__c = lenderName;
            newLending.Lending_date__c = lendingDate;
            newLending.Return_status__c = returnStatus;
            insert newLending;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating lending record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void markAsReturned(Id lendingId) {
        if (String.isBlank(lendingId)) {
            throw new AuraHandledException('Lending record ID ir nepieciešams.');
        }

        try {
            Lending_History__c record = [SELECT Id, Return_status__c, Return_date__c
                                        FROM Lending_History__c
                                        WHERE Id = :lendingId
                                        LIMIT 1];

            record.Return_status__c = 'Returned';
            record.Return_date__c = Date.today();
            update record;
        } catch (Exception e) {
            throw new AuraHandledException('Kļūda atjauninot aizņemšanās ierakstu: ' + e.getMessage());
        }
    }

}
