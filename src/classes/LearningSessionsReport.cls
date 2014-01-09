public class LearningSessionsReport 
{
	ID tutorID=null;
	public List<Learning_Session__c> sessions;
 	public LearningSessionsReport(ApexPages.StandardController controller)
    {
    	User currentUser = [select id, contactID FROM User WHERE id =: UserInfo.getUserId()];
  	 	tutorID = currentUser.ContactId;
        Initialise ();
    }

 	public LearningSessionsReport()
    {
        Initialise ();
    }

    private void Initialise ()
    {
     	sessions = [select Id, Name, Date__c, Cost_of_session__c, Learner__c, Learner__r.Name, Learner__r.OwnerID, Learner_name__c, RecordTypeID from Learning_Session__c where Tutor__c = :tutorID order by Date__c desc limit 1000];
    }
    
    public List<Learning_Session__c> getSessions ()
    {
    	return sessions;
    }
    
    public ID getCurrentUserID ()
    {
    	return UserInfo.getUserId();
    }
    
    public PageReference displayAllSessions()
    {
    	Initialise();
       //returning null indicates the same page should be returned - in place change
       return null;
    }  
    
    public PageReference displayLastMonthSessions()
    {
    	sessions = [select Id, Name, Date__c, Cost_of_session__c, Learner__c, Learner__r.Name, Learner__r.OwnerID, Learner_name__c, RecordTypeID from Learning_Session__c where Tutor__c = :tutorID and Date__c=LAST_MONTH order by Date__c desc limit 1000];
       //returning null indicates the same page should be returned - in place change
       return null;
    }  

    public PageReference displayThisMonthSessions()
    {
    	sessions = [select Id, Name, Date__c, Cost_of_session__c, Learner__c, Learner__r.Name, Learner__r.OwnerID, Learner_name__c, RecordTypeID from Learning_Session__c where Tutor__c = :tutorID and Date__c=THIS_MONTH order by Date__c desc limit 1000];
       //returning null indicates the same page should be returned - in place change
       return null;
    }  

    public static testMethod void testGetSessions ()
    {
    	RecordType tutorType = [SELECT ID, Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName='Tutor_or_LSW'];
    	
    	Contact internalTutor = new Contact (LastName='Internal', RecordTypeID = tutorType.ID);
    	insert internalTutor;
    	
    	Contact tutor = new Contact (LastName='Tutor', RecordTypeID = tutorType.ID);
    	insert tutor;
        LearningSessionsReport controller = new LearningSessionsReport ();
        
        controller.tutorID = tutor.id;
  	
	   	Contact lsw = new Contact (LastName='LSW', RecordTypeID = tutorType.ID);
    	insert lsw;
        Learner__c learner = new Learner__c (First_Name__c = 'First', Last_Name__c='Last', Current_DL_status__c ='Assigned to tutor', Tutor_for_DL__c=tutor.id, Learning_Support_Worker__c=lsw.id, Address__c='Some address');
        insert learner;
        
        learner = [select ID, OwnerID from Learner__c where id=:learner.id limit 1];
        Learning_Session__c session = new Learning_Session__c (Learner__c = learner.id);
        insert session;
        
        controller.getSessions();
        
        controller.getCurrentUserID();
     }
}