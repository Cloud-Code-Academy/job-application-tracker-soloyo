@isTest
private class JobAppTriggerTest {

    @isTest
    static void testCreateTask() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 5; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Applied',
                Application_Date__c = Date.today().addDays(-i),
                Interview_Date__c = Date.today().addDays(i),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;
        
        List<Task> tasks = [select Id, Subject from Task where Subject LIKE '%Job Application%'];

        System.assertEquals(5, tasks.size(), 'Five tasks should have been created.');
    }

    @isTest
    static void testCreateEvent() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 5; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Applied',
                Application_Date__c = Date.today(),
                Interview_Date__c = Date.today().addDays(2),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;
        
        List<Event> events = [select Id, Subject from Event where Subject LIKE '%Interview%'];

        System.assertEquals(5, events.size(), 'Five events should have been created.');
    }

    @isTest
    static void testUpdateEvent() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 5; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Applied',
                Application_Date__c = Date.today(),
                Interview_Date__c = Date.today().addDays(2),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;

        // grab the new applications and create events
        List<Job_Application__c> newJobApps = [select Id, Company_Name__c, Position__c from Job_Application__c where Id in :testApplications];

        //change the interview to today + 3 days
        for (Job_Application__c jobApp : newJobApps) {
            jobApp.Interview_Date__c = Date.today().addDays(3);
        }
    
        update newJobApps;

        Date dateToCheck = Date.today();
        
        List<Event> events = [select Id from Event where ActivityDate > :dateToCheck];

        System.assertEquals(5, events.size(), 'Five events should have been created.');
    }

    @isTest
    static void testDeleteEvent() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>(); 

        for (Integer i = 0; i < 5; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = 'Saved',
                Application_Date__c = Date.today(),
                Interview_Date__c = Date.today().addDays(2),
                URL__c = 'http://example.com/job' + i
            )); 
        }
        
        insert testApplications; // this should trigger an event creation

        List<Event> events = [select Id from Event where Subject LIKE '%Interview%'];

        System.assertEquals(5, events.size(), 'Five events should have been created.');

        delete testApplications;

        // check if the events are deleted
        List<Event> deletedEvents = [select Id from Event where Subject LIKE '%Interview%'];
        System.assertEquals(0, deletedEvents.size(), 'All events should have been deleted.');
    }

    @isTest
    static void testSetDefaultStatus() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 5; i++) {
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Application_Date__c = Date.today(),
                Follow_up_Date__c = Date.today().addDays(2),
                URL__c = 'http://example.com/job' + i
            ));
        }
        
        insert testApplications;

        // check if the status is set to 'Saved'
        List<Job_Application__c> updatedApplications = [select Id, Status__c from Job_Application__c where Id in :testApplications];

        for (Job_Application__c jobApp : updatedApplications) {
            System.assertEquals('Saved', jobApp.Status__c, 'Status should be set to Saved.');
        }
    }
}