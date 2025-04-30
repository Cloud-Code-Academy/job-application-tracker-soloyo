@isTest
private class TaskNotificationsTest {

    @testSetup
    static void setupTestData() {
        Profile p = [select Id from Profile where Name = 'Standard User'];
        
        User testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@example.com',
            Username = 'testuser1_' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id,
            Alias = 'tuser1',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        
        insert new List<User>{ testUser1 };

        System.runAs(testUser1) {
            Task task1 = new Task(
                Subject = 'Task 1 Tomorrow',
                ActivityDate = Date.today().addDays(1),
                Description = 'Description for Task 1',
                OwnerId = testUser1.Id,
                Status = 'Not Started'
            );
            
            Task task2 = new Task(
                Subject = 'Task 2 Tomorrow',
                ActivityDate = Date.today().addDays(1),
                OwnerId = testUser1.Id,
                Status = 'In Progress'
            );
            
            // overdue
            Task task3 = new Task(
                Subject = 'Task 3 Overdue',
                ActivityDate = Date.today().addDays(-3),
                Description = 'Description for Task 3',
                OwnerId = testUser1.Id,
                Status = 'Not Started'
            );

            // completed
            Task task4 = new Task(
                Subject = 'Task 4 Completed',
                ActivityDate = Date.today().addDays(1),
                Status = 'Completed'
            );
            
            insert new List<Task>{ task1, task2, task3, task4 };
        }
    }

    @isTest
    static void testUpcomingTaskScheduleExecution() {
        
        Test.startTest();
        TaskNotificationsScheduler.setupNotifications();
        
        TaskNotificationsScheduler.UpcomingTaskSchedule upcomingSchedule = new TaskNotificationsScheduler.UpcomingTaskSchedule();

        upcomingSchedule.execute(null);
        Test.stopTest();
    }

    @isTest
    static void testOverdueTaskScheduleExecution() {
        
        Test.startTest();
        TaskNotificationsScheduler.setupNotifications();
        
        TaskNotificationsScheduler.OverdueTaskSchedule overdueSchedule = new TaskNotificationsScheduler.OverdueTaskSchedule ();
        
        overdueSchedule.execute(null);
        Test.stopTest();
    }

    @isTest
    static void testSetupNotifications() {
        Test.startTest();
        TaskNotificationsScheduler.setupNotifications();
        Test.stopTest();

        List<CronTrigger> jobs = [
            select Id, CronJobDetail.Name from CronTrigger
            where CronJobDetail.Name in ('Upcoming Task Notification Job', 'Overdue Task Notification Job')
        ];

        System.assertEquals(2, jobs.size(), 'Expected 2 scheduled jobs');
        System.assertEquals('Upcoming Task Notification Job', jobs[0].CronJobDetail.Name, 'Expected job name to be Upcoming Task Notification Job');
        System.assertEquals('Overdue Task Notification Job', jobs[1].CronJobDetail.Name, 'Expected job name to be Overdue Task Notification Job');
    }

    @isTest
    static void testUpcomingTasksNotifications() {
        Test.startTest();
        Integer emailsInvocations = Limits.getEmailInvocations();
        
        TasksNotifications.upcomingTasksNotifications();
        
        Test.stopTest();

        System.assertEquals(emailsInvocations, Limits.getEmailInvocations(), 'Expected emails to be sent to 1 user');
        
        List<Task> tomorrowTasks = [
            select Id from Task
            where ActivityDate = :Date.today().addDays(1) and Status != 'Completed'
        ];

        System.assertEquals(2, tomorrowTasks.size(), 'Should have 2 active tasks due tomorrow');
    }

    @isTest
    static void testOverdueTasksNotifications() {
        Test.startTest();
        Integer emailsInvocations = Limits.getEmailInvocations();
        
        TasksNotifications.overdueTasksNotifications();
        
        Test.stopTest();

        System.assertEquals(emailsInvocations, Limits.getEmailInvocations(), 'Expected emails to be sent to 1 user');
        
        List<Task> overdueTasks = [
            select Id from Task
            where ActivityDate < :Date.today() and Status != 'Completed'
        ];

        System.assertEquals(1, overdueTasks.size(), 'Should have 1 overdue task');
    }
}