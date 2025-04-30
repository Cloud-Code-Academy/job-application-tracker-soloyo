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

    @isTest
    static void testGetUpcomingInterviews() {
        List<Event> testEvents = new List<Event>();

        for (Integer i = 0; i < 5; i++) {
            testEvents.add(new Event(
                Subject = 'Interview with Test Company ' + i,
                StartDateTime = System.now().addDays(i),
                EndDateTime = System.now().addDays(i).addHours(1),
                OwnerId = UserInfo.getUserId()
            ));
        }

        insert testEvents;

        Test.startTest();
        List<Event> upcomingInterviews = DashboardController.getUpcomingInterviews();
        Test.stopTest();

        System.assertEquals(5, upcomingInterviews.size(), 'Upcoming interviews count is incorrect.');
    }

    @isTest
    static void testGetNoUpcomingInterviews() {
        List<Event> testEvents = new List<Event>();

        for (Integer i = 0; i < 5; i++) {
            testEvents.add(new Event(
                Subject = 'Interview with Test Company ' + i,
                StartDateTime = System.now().addDays(-5),
                EndDateTime = System.now().addDays(-5).addHours(1),
                OwnerId = UserInfo.getUserId()
            ));
        }

        insert testEvents;

        Test.startTest();
        List<Event> upcomingInterviews = DashboardController.getUpcomingInterviews();
        Test.stopTest();

        System.assertEquals(0, upcomingInterviews.size(), 'Upcoming interviews count is incorrect.');
    }

    @isTest
    static void testGetPendingTasks() {
        List<Task> testTasks = new List<Task>();

        for (Integer i = 0; i < 10; i++) {
            String taskStatus;

            switch on i {
                when 0, 4, 6, 7 {
                    taskStatus = 'Not Started';
                }	
                when 1, 2, 9 {
                    taskStatus = 'In Progress';
                }
                when 3 {
                    taskStatus = 'Completed';
                }
                when else {
                    taskStatus = 'Deferred';
                }
            }

            testTasks.add(new Task(
                Subject = 'Follow up on application ' + i,
                ActivityDate = Date.today().addDays(i + 2),
                Status = taskStatus,
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            ));
        }

        insert testTasks;

        Test.startTest();
        List<Task> pendingTasks = DashboardController.getPendingTasks();
        Test.stopTest();

        System.assertEquals(9, pendingTasks.size(), 'Pending tasks count is incorrect.');
        System.assertNotEquals(10, pendingTasks.size(), 'Pending tasks count is incorrect.');
    }

    @isTest
    static void testGetNoPendingTasks() {
        List<Task> testTasks = new List<Task>();

        for (Integer i = 0; i < 5; i++) {
            testTasks.add(new Task(
                Subject = 'Follow up on application ' + i,
                ActivityDate = Date.today().addDays(-2),
                Status = 'Completed',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            ));
        }

        insert testTasks;

        Test.startTest();
        List<Task> pendingTasks = DashboardController.getPendingTasks();
        Test.stopTest();

        System.assertEquals(0, pendingTasks.size(), 'Pending tasks count is incorrect.');
    }

    @isTest
    static void testCompletedTask() {
        List<Task> testTasks = new List<Task>();

        for (Integer i = 0; i < 5; i++) {
            testTasks.add(new Task(
                Subject = 'Follow up on application ' + i,
                ActivityDate = Date.today().addDays(i + 2),
                Status = 'Not Started',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            ));
        }

        insert testTasks;

        Test.startTest();
        DashboardController.completedTask(testTasks[0].Id);
        Test.stopTest();

        Task updatedTask = [select Id, Status from Task where Id = :testTasks[0].Id];

        System.assertEquals(5, testTasks.size(), 'Tasks count is incorrect.');
        System.assertEquals('Completed', updatedTask.Status, 'Task status was not updated correctly.');
    }
}