public with sharing class BookInUserCollectionController {

    @AuraEnabled
    public static List<BookInUserCollection__c> getBooks(String collectionType) {
        Id currentUserId = UserInfo.getUserId();

        String query = 'SELECT Id, Book__r.Name, Book__r.Author__r.Name, Book__r.Author__r.Surname__c, Book__r.Genre__r.Name, Book__r.Book_cover__c, Reading_status__c FROM BookInUserCollection__c WHERE User__c = :currentUserId';

        if (collectionType == 'readBooks') {
            query += ' AND Reading_status__c = \'Izlasīta\'';
        } else if (collectionType == 'wantToRead') {
            query += ' AND Reading_status__c = \'Gribu izlasīt\'';
        }

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<BookInUserCollection__c> getCurrentlyReadingBooks() {
        try {
            return [
                SELECT Id,
                       Current_page__c,
                       Book__r.Name,
                       Book__r.Author__r.Name,
                       Book__r.Author__r.Surname__c,
                       Book__r.Number_of_pages__c
                FROM BookInUserCollection__c
                WHERE Reading_status__c = 'Pašlaik lasu'
                  AND User__c = :UserInfo.getUserId()
                ORDER BY LastModifiedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching currently reading books: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateCurrentPage(Id bookId, Integer currentPage) {
        try {
            BookInUserCollection__c book = [
                SELECT Id, Current_page__c, Book__r.Number_of_pages__c 
                FROM BookInUserCollection__c 
                WHERE Id = :bookId 
                LIMIT 1
            ];

            if (currentPage < 1) {
                throw new AuraHandledException('Current page cannot be less than 1.');
            }

            if (currentPage > book.Book__r.Number_of_pages__c) {
                throw new AuraHandledException(
                    'Current page cannot exceed the total number of pages in the book (' + book.Book__r.Number_of_pages__c + ').'
                );
            }

            book.Current_page__c = currentPage;
            update book;

        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void markBookAsCompleted(Id bookId) {
        if (String.isBlank(bookId)) {
            throw new AuraHandledException('The book ID is required.');
        }

        BookInUserCollection__c book = [
            SELECT Id, Current_page__c, Times_read__c, Date_finished__c, Reading_status__c
            FROM BookInUserCollection__c
            WHERE Id = :bookId
            LIMIT 1
        ];

        book.Reading_status__c = 'Izlasīta';
        book.Date_finished__c = Date.today();
        book.Times_read__c = (book.Times_read__c != null ? book.Times_read__c + 1 : 1);
        book.Current_page__c = 0;

        update book;
    }

    @AuraEnabled
    public static void addToCollection(Id bookId, String readingStatus, Date dateBought, String isbn) {
        if (bookId == null) {
            throw new AuraHandledException('Book ID is required.');
        }
        if (String.isBlank(readingStatus)) {
            throw new AuraHandledException('Reading status is required.');
        }

        if (dateBought == null) {
            dateBought = Date.today();
        }

        if (dateBought > Date.today()) {
            throw new AuraHandledException('Date bought cannot be in the future.');
        }

        BookInUserCollection__c newCollectionEntry = new BookInUserCollection__c(
            Book__c = bookId,
            Reading_status__c = readingStatus,
            Date_bought__c = dateBought,
            ISBN__c = isbn,
            User__c = UserInfo.getUserId(),
            Times_read__c = readingStatus == 'Izlasīta' ? 1 : 0,
            Current_page__c = 0
        );

        try {
            insert newCollectionEntry;
        } catch (Exception e) {
            throw new AuraHandledException('Error adding book to collection: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static BookInUserCollection__c getBookCollectionDetails(Id recordId) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('The record ID is required.');
        }

        try {
            return [
                SELECT Id,
                       Book__c,
                       Book__r.Name, 
                       Book__r.Author__r.Name, 
                       Book__r.Author__r.Surname__c,
                       Book__r.Genre__r.Name,
                       Book__r.Book_cover__c,
                       Book__r.Number_of_pages__c,
                       Current_page__c,
                       Times_read__c,
                       Date_started__c,
                       Date_finished__c,
                       Date_bought__c,
                       ISBN__c,
                       Format__c,
                       Reading_status__c
                FROM BookInUserCollection__c
                WHERE Id = :recordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching the book collection details.');
        }
    }

    @AuraEnabled
    public static void updateBookCollection(BookInUserCollection__c bookInUserCollection) {
        if (bookInUserCollection.Date_started__c != null) {
            if (bookInUserCollection.Date_started__c > Date.today()) {
                throw new AuraHandledException('Datums, kad sāka lasīt, nevar būt nākotnē.');
            }
        } else {
            bookInUserCollection.Date_started__c = null;
        }

        if (bookInUserCollection.Date_finished__c != null) {
            if (bookInUserCollection.Date_finished__c > Date.today()) {
                throw new AuraHandledException('Datums, kad pabeidza lasīt, nevar būt nākotnē.');
            }
        } else {
            bookInUserCollection.Date_finished__c = null;
        }

        if (bookInUserCollection.Format__c == 'Nav norādīts' || String.isBlank(bookInUserCollection.Format__c)) {
            bookInUserCollection.Format__c = null;
        }

        if (bookInUserCollection.Reading_status__c == 'Nav' || String.isBlank(bookInUserCollection.Reading_status__c)) {
            bookInUserCollection.Reading_status__c = null;
        }

        try {
            update bookInUserCollection;
        } catch (Exception e) {
            throw new AuraHandledException('Kļūda atjauninot grāmatu kolekciju: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void deleteBookFromCollection(Id recordId) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('The record ID is required for deletion.');
        }

        try {
            delete [SELECT Id FROM BookInUserCollection__c WHERE Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting the book from the collection.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Book__c> getRecommendedBooks(Id bookCollectionId) {
        if (String.isBlank(bookCollectionId)) {
            throw new AuraHandledException('Book collection ID is required.');
        }

        BookInUserCollection__c collection = [
            SELECT Book__c, Book__r.Genre__c, Book__r.Author__r.Name, Book__r.Author__r.Surname__c
            FROM BookInUserCollection__c
            WHERE Id = :bookCollectionId
            LIMIT 1
        ];

        if (collection == null || collection.Book__r.Genre__c == null) {
            throw new AuraHandledException('No genre information found for this book.');
        }

        List<Book__c> recommendedBooks = [
            SELECT Id, Name, Book_cover__c, Author__r.Name, Author__r.Surname__c
            FROM Book__c
            WHERE Genre__c = :collection.Book__r.Genre__c
              AND Id != :collection.Book__c
            LIMIT 10
        ];

        return recommendedBooks;
    }

}
