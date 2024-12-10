public with sharing class BookController {
    @AuraEnabled
    public static List<Author__c> getAuthors() {
        return [SELECT Id, Name, Surname__c FROM Author__c ORDER BY Name, Surname__c];
    }

    @AuraEnabled
    public static List<Genre__c> getGenres() {
        return [SELECT Id, Name FROM Genre__c ORDER BY Name];
    }

    @AuraEnabled
    public static List<Map<String, String>> getBookOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        List<Book__c> books = [SELECT Id, Name FROM Book__c ORDER BY Name];

        for (Book__c book : books) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', book.Name);
            option.put('value', book.Id);
            options.add(option);
        }

        return options;
    }

    @AuraEnabled
    public static List<Book__c> getBooks(String title, String author, String genre) {
        String titleFilter = '%' + title + '%';
        String authorFilter = '%' + author + '%';
        String genreFilter = '%' + genre + '%';

        String query = 'SELECT Id, Name, Author__r.Name,Author__r.Surname__c, Number_of_pages__c, Book_cover__c, Genre__r.Name FROM Book__c ';

        Boolean hasFilter = !String.isBlank(title) || !String.isBlank(author) || !String.isBlank(genre);

        if (hasFilter) {
            query += 'WHERE ';
            List<String> conditions = new List<String>();
            
            if (!String.isBlank(title)) {
                conditions.add('Name LIKE :titleFilter');
            }
            if (!String.isBlank(author)) {
                conditions.add('Author__r.Name LIKE :authorFilter');
            }
            if (!String.isBlank(genre)) {
                conditions.add('Genre__r.Name LIKE :genreFilter');
            }

            query += String.join(conditions, ' AND ');
        }

        return Database.query(query);
    }

    @AuraEnabled
    public static Id addBook(
        String name,
        Date publicationDate,
        Integer numberOfPages,
        String description,
        Id authorId,
        Id genreId,
        String bookCover
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
            Author__c = authorId,
            Genre__c = genreId,
            Book_cover__c = bookCover
        );

        try {
            insert newBook;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating new book: ' + e.getMessage());
        }

        return newBook.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Book__c getBookDetails(Id bookId) {
        try {
            // Query for book details
            return [
                SELECT Id, Name, Number_of_pages__c, Publication_date__c, Description__c, 
                       Book_cover__c, Author__c, Author__r.Name, Author__r.Surname__c, Genre__r.Name
                FROM Book__c
                WHERE Id = :bookId
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching book details: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<Book__c> getBooksByAuthor(Id authorId) {
        return [
            SELECT Id, Name, Book_cover__c
            FROM Book__c
            WHERE Author__c = :authorId
            ORDER BY Name ASC
        ];
    }

}
