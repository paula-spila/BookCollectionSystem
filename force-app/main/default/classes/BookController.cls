public with sharing class BookController {
    @AuraEnabled(cacheable=true)
    public static List<Book__c> getBooks() {
        return [
            SELECT Id, Name, Author__r.Name, Genre__r.Name, Date_added__c, Number_of_pages__c
            FROM Book__c
        ];
    }   

    @AuraEnabled
    public static List<Author__c> getAuthors() {
        return [SELECT Id, Name FROM Author__c];
    }

    @AuraEnabled
    public static List<Genre__c> getGenres() {
        return [SELECT Id, Name FROM Genre__c];
    }

    @AuraEnabled
    public static Id addBook(
        String name,
        Date publicationDate,
        Integer numberOfPages,
        String description,
        Date dateAdded,
        Id authorId,
        Id genreId,
        String isbn
    ) {
        // Validate required fields
        if (String.isBlank(name)) {
            throw new AuraHandledException('Missing required field: Book Name.');
        }

        // Validate publication date (cannot be in the future)
        if (publicationDate != null && publicationDate > Date.today()) {
            throw new AuraHandledException('Publication date cannot be in the future.');
        }

        // Validate number of pages (positive integer)
        if (numberOfPages != null && numberOfPages <= 0) {
            throw new AuraHandledException('Number of pages must be a positive integer.');
        }

        if (dateAdded != null && dateAdded > Date.today()) {
            throw new AuraHandledException('Added date cannot be in the future.');
        }
        // Validate description length
        if (!String.isBlank(description) && description.length() > 3000) {
            throw new AuraHandledException('Description should not exceed 3000 characters.');
        }
    
        // Create the Book record
        Book__c newBook = new Book__c(
            Name = name,
            Publication_Date__c = publicationDate,
            Number_of_Pages__c = numberOfPages,
            Description__c = description,
            Date_Added__c = dateAdded,
            Author__c = authorId,
            Genre__c = genreId,
            ISBN__c = isbn
        );

        try {
            insert newBook;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating new book: ' + e.getMessage());
        }

        return newBook.Id;
    }
}
