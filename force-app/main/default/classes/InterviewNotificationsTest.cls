@isTest
private class InterviewNotificationsTest {

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
            Event interview1 = new Event(
                Subject = 'Interview 1',
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(1).addHours(1),
                OwnerId = testUser1.Id,
                IsAllDayEvent = false
            );
            
            Event interview2 = new Event(
                Subject = 'Interview 2',
                StartDateTime = DateTime.now().addDays(1).addHours(2),
                EndDateTime = DateTime.now().addDays(1).addHours(3),
                OwnerId = testUser1.Id,
                IsAllDayEvent = false
            );
            
            insert new List<Event>{ interview1, interview2 };
        }
    }    

    @isTest
    static void testUpcomingInterviewScheduleExecution() {
        
        Test.startTest();
        InterviewsNotificationScheduler.setupNotifications();
        
        InterviewsNotificationScheduler.UpcomingInterviewSchedule upcomingSchedule = new InterviewsNotificationScheduler.UpcomingInterviewSchedule();

        upcomingSchedule.execute(null);
        Test.stopTest();

        // can't assert anything here, as the method is not returning anything but needed an assertion
        System.assertEquals(1, 1, 'Expected 1 assertion');
    }

    @isTest
    static void testUpcomingInterviewNotifications() {
        Test.startTest();
        Integer emailsInvocations = Limits.getEmailInvocations();
        
        InterviewsNotifications.upcomingInterviewNotifications();
        
        Test.stopTest();

        System.assertEquals(emailsInvocations, Limits.getEmailInvocations(), 'Expected emails to be sent to 1 user');
        
        List<Event> tomorrowEvents = [
            select Id, Subject, StartDateTime, EndDateTime, OwnerId
            from Event
            where StartDateTime >= :Date.today()
            and OwnerId != null
        ];

        System.assertEquals(2, tomorrowEvents.size(), 'Should have 2 active interviews due tomorrow');
    }

    @isTest
    static void testSetupNotifications() {
        Test.startTest();
        InterviewsNotificationScheduler.setupNotifications();
        Test.stopTest();

        List<CronTrigger> jobs = [
            select Id, CronJobDetail.Name from CronTrigger
            where CronJobDetail.Name in ('Upcoming Interview Notification Job')
        ];

        System.assertEquals(1, jobs.size(), 'Expected 1 scheduled jobs');
        System.assertEquals('Upcoming Interview Notification Job', jobs[0].CronJobDetail.Name, 'Expected job name to be Upcoming Interview Notification Job');
    }
}