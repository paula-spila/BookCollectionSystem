public with sharing class LendingHistoryController {
    @AuraEnabled
    public static Id createLending(Id bookId, String lendingHistoryName, Date lendingDate, Date returnDate, String returnStatus) {
        if (bookId == null || String.isBlank(lendingHistoryName)) {
            throw new AuraHandledException('Missing required fields: Book and Lending History Name.');
        }

        if (bookId == null) {
            throw new AuraHandledException('Missing required field: Book.');
        }
        if (String.isBlank(lendingHistoryName)) {
            throw new AuraHandledException('Missing required field: Lending History Name.');
        }
    
        if (lendingDate != null && lendingDate > Date.today()) {
            throw new AuraHandledException('Lending date cannot be in the future.');
        }
        if (returnDate != null && returnDate < lendingDate) {
            throw new AuraHandledException('Return date cannot be earlier than the lending date.');
        }
    
        if (returnDate != null && String.isBlank(returnStatus)) {
            throw new AuraHandledException('Return status must be provided if return date is set.');
        }
    
        if (lendingHistoryName.length() > 80) {
            throw new AuraHandledException('Lending History Name should not exceed 80 characters.');
        }

        Lending_History__c newLending = new Lending_History__c(
            Book__c = bookId,
            Name = lendingHistoryName,
            Lending_date__c = lendingDate,
            Return_date__c = returnDate,
            Return_status__c = returnStatus
        );

        try {
            insert newLending;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('Error creating new lending: ' + e.getMessage());
        }

        return newLending.Id;
    }

    @AuraEnabled
    public static List<Map<String, String>> getReturnStatusOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Lending_History__c.Return_status__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', entry.getLabel());
            option.put('value', entry.getValue());
            options.add(option);
        }

        return options;
    }
}
