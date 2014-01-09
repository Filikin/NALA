@isTest
private class TestTriggers 
{
    static testMethod void testCreateLearningSession() 
    {
    	RecordType tutorType = [SELECT ID, Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName='Tutor_or_LSW'];
    	
    	Contact internalTutor = new Contact (LastName='Internal', RecordTypeID = tutorType.ID);
    	insert internalTutor;
    	
    	Contact tutor = new Contact (LastName='Tutor', RecordTypeID = tutorType.ID);
    	insert tutor;
    	
    	User tUser = createCustomerUser(tutor.id, 'Test@eamon.com', 'lastName');
    	
	   	Contact lsw = new Contact (LastName='LSW', RecordTypeID = tutorType.ID);
    	insert lsw;
        Learner__c learner = new Learner__c (First_Name__c = 'First', Last_Name__c='Last', Current_DL_status__c ='Assigned to tutor', Tutor_for_DL__c=tutor.id, Learning_Support_Worker__c=lsw.id, Address__c='Some address');
        insert learner;
        
        learner = [select ID, OwnerID from Learner__c where id=:learner.id limit 1];
        Learning_Session__c session = new Learning_Session__c (Learner__c = learner.id);
        insert session;
        
        session = [select id, Tutor__c from Learning_Session__c where id=:session.id limit 1];
        System.AssertEquals (session.Tutor__c, tutor.id);
        
        System.AssertEquals (tUser.id, learner.OwnerId);
        
      	Contact tutor2 = new Contact (LastName='Tutor2', RecordTypeID = tutorType.ID);
    	insert tutor2;
        User tUser2 = createCustomerUser(tutor2.id, 'Test2@eamon.com', 'lastName2');
        learner.Tutor_for_DL__c = tutor2.id;
        update learner;
        learner = [select ID, OwnerID from Learner__c where id=:learner.id limit 1];
       	System.AssertEquals (tUser2.id, learner.OwnerId);
        
        learner.Current_DL_status__c = 'Assigned to LSW';
        learner.Learning_Support_Worker__c = tutor.id;
        update learner;
        learner = [select ID, OwnerID from Learner__c where id=:learner.id limit 1];
       	System.AssertEquals (tUser.id, learner.OwnerId);
        
        User tUser3 = createCustomerUser(lsw.id, 'Test3@eamon.com', 'lastName3');
        Learner__c learner2 = new Learner__c (First_Name__c = 'First2', Last_Name__c='Last2', Current_DL_status__c ='Assigned to LSW', Tutor_for_DL__c=tutor.id, Learning_Support_Worker__c=lsw.id, Address__c='Some address');
        insert learner2;
        learner2 = [select ID, OwnerID from Learner__c where id=:learner2.id limit 1];
       	System.AssertEquals (tUser3.id, learner2.OwnerId);
        
        /* trace the path of a learner
	        Interested Party
			Waiting for LSW to be assigned
			Assigned to LSW, awaiting assessment
			Assessment complete, awaiting tutor
			Assigned to tutor
			Learning sessions complete, no further action
			Learning sessions complete, joined a learning centre
			Learning sessions complete, moved to online learning
			Left program
		*/
        Learner__c testLearner = new Learner__c (First_Name__c = 'Test', Last_Name__c='Learner', Current_DL_status__c ='Interested Party', Address__c='Some address', Contact_Number__c='0234567');
        insert testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, NULL);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, NULL);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());
		       	
        testLearner.Current_DL_status__c = 'Waiting for LSW to be assigned';
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, NULL);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, NULL);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());

        testLearner.Current_DL_status__c = 'Assigned to LSW, awaiting assessment';
        testLearner.Learning_Support_Worker__c = lsw.id;
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, NULL);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, lsw.id);
		System.AssertEquals (testLearner.OwnerID, tUser3.id);
        
        testLearner.Current_DL_status__c = 'Assessment complete, awaiting tutor';
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, NULL);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, internalTutor.id);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());

        testLearner.Current_DL_status__c = 'Assigned to tutor';
        testLearner.Tutor_for_DL__c = tutor2.id;
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, tutor2.id);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, internalTutor.id);
		System.AssertEquals (testLearner.OwnerID, tUser2.id);

        testLearner.Current_DL_status__c = 'Learning sessions complete, no further action';
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, internalTutor.id);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, internalTutor.id);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());

	    testLearner.Current_DL_status__c = 'Learning sessions complete, joined a learning centre';
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, internalTutor.id);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, internalTutor.id);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());

	    testLearner.Current_DL_status__c = 'Learning sessions complete, moved to online learning';
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, internalTutor.id);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, internalTutor.id);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());

	    testLearner.Current_DL_status__c = 'Left program';
        update testLearner;
        
       	testLearner = [select ID, OwnerID, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where id=:testLearner.id limit 1];
       	System.AssertEquals (testLearner.Tutor_for_DL__c, internalTutor.id);
       	System.AssertEquals (testLearner.Learning_Support_Worker__c, internalTutor.id);
		System.AssertEquals (testLearner.OwnerID, UserInfo.getUserId());
 
        testLearner.Current_DL_status__c = 'Assigned to tutor';
        testLearner.Tutor_for_DL__c = null;
        try
        {
	        update testLearner;
        }
        catch (Exception e)
        {
			        	
        }

        testLearner.Current_DL_status__c = 'Assigned to LSW, awaiting assessment';
        testLearner.Learning_Support_Worker__c = null;
        try
        {
	        update testLearner;
        }
        catch (Exception e)
        {
			        	
        }
    }
    
    public static User createCustomerUser(Id contactId, String username, String lastName )
    {
        String profileName = 'NALA DL Website';

        String alias = username.split('@').get(0);
       
        Profile profile = [select Id from Profile where Name=:profileName];
       
         
        User user = new User(
            ContactId = contactId,
            Username = username,
            Email = username,
            LastName = lastName,
            Alias = alias,
            ProfileID = profile.Id,
            PortalRole = 'Manager',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8'
        );
        insert user;
       
        return user;
    }
}