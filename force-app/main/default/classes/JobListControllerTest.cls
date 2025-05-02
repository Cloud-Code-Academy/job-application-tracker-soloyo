@isTest
private class JobListControllerTest {

    @TestSetup
    static void jobListSetupData() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 5; i++) {
            String appStatus;

            switch on i {
                when 0, 4 {
                    appStatus = 'Saved';
                }
                when 1 {
                    appStatus = 'Applied';
                }
                when 2 {
                    appStatus = 'Interviewing';
                }
                when else {
                    appStatus = 'Accepted';
                }
            }

            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Status__c = appStatus,
                Application_Date__c = Date.today().addDays(-i),
                Interview_Date__c = Date.today().addDays(i),
                URL__c = 'http://example.com/job' + i
            ));
        }

        insert testApplications;
    }

    @isTest
    static void testGetAllJobs() {        
        Test.startTest();
        List<Job_Application__c> jobs = JobsListController.getAllJobs();
        Test.stopTest();

        System.assertNotEquals(null, jobs, 'The job list should not be null');
        System.assertEquals(5, jobs.size(), 'The job list should contain 5 job applications');
    }

    @isTest
    static void testGetAllJobsDifferentUser() {
        Profile p = [select Id from Profile where Name = 'Standard User'];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );

        insert testUser;

        Test.startTest();
        List<Job_Application__c> jobs = JobsListController.getAllJobs();
        Test.stopTest();

        System.assertNotEquals(0, jobs.size(), 'Should not return jobs for a different user');
    }
}