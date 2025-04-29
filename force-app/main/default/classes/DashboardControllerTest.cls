@isTest
private class DashboardControllerTest {

    @isTest
    static void testGetApplicationStats() {
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
                    appStatus = 'Negotiating';
                }
            }

            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Application_Date__c = Date.today().addDays(-i),
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Notes__c = 'Test notes for application ' + i,
                Status__c = appStatus
            ));
        }

        insert testApplications;
        
        Test.startTest();
        Map<String, Integer> stats = DashboardController.getApplicationStats();
        Test.stopTest();
        
        System.assertEquals(5, stats.get('total'), 'Total applications count is incorrect.');
        System.assertEquals(1, stats.get('applied'), 'Applied applications count is incorrect.');
        System.assertEquals(1, stats.get('interviews'), 'Interview applications count is incorrect.');
        System.assertEquals(1, stats.get('offers'), 'Offers applications count is incorrect.');
    }

    @isTest
    static void testGetRecentApplications() {
        List<Job_Application__c> testApplications = new List<Job_Application__c>();

        for (Integer i = 0; i < 10; i++) { // 
            testApplications.add(new Job_Application__c(
                Company_Name__c = 'Test Company ' + i,
                Application_Date__c = Date.today().addDays(-i),
                Position__c = 'Test Position ' + i,
                Salary__c = 50000 + (i * 1000),
                Notes__c = 'Test notes for application ' + i,
                Status__c = 'Applied'
            ));
        }

        insert testApplications;

        Test.startTest();
        List<Job_Application__c> recentApps = DashboardController.getRecentApplications();
        Test.stopTest();

        System.assertEquals(5, recentApps.size(), 'Recent applications count is incorrect.');
        System.assertNotEquals(10, recentApps.size(), 'Total applications count is correct.');
    }
}