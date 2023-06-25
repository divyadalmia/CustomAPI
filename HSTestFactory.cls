@isTest
public with sharing class TestFactory {
    
    public static User UserCreate() { 
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj; 
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/New_York', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         UserRoleId = obj.Id);
        insert uu;
        
        return uu;
    } 
    
    public static OperatingHours creatOperatingHours(string name, String timeZone ){
        OperatingHours operatingHoursObj = new OperatingHours(Name = name,TimeZone = timeZone);
        insert operatingHoursObj;
        return operatingHoursObj;
    }
    
    public static TimeSlot creatTimeSlot(OperatingHours operatingHoursObj, Time startTime, Time endTime ){
        TimeSlot timeSlotObj = new TimeSlot(OperatingHoursId = operatingHoursObj.Id,StartTime = startTime,EndTime = endTime);                 
        insert timeSlotObj;
        return timeSlotObj;
    }
    
    public static ServiceTerritory creatServiceTerritory(string name, OperatingHours operatingHoursObj,boolean isActive  ){
        ServiceTerritory serviceTerritoryObj = new ServiceTerritory(Name = name,OperatingHoursId = operatingHoursObj.Id,IsACTIVE = isActive);
        Insert serviceTerritoryObj;
        return serviceTerritoryObj;
    }
    
    public static WorkOrder createWorkOrder(){
        WorkOrder workOrderObj = new WorkOrder();
        insert workOrderObj;
        return workOrderObj;
    }
    
    public static ServiceAppointment createSA(WorkOrder workOrderObj,string status, DateTime earlyStart, DateTime dueDate, ServiceTerritory serviceTerritoryObj){
        
        ServiceAppointment serviceAppointmentObj = new ServiceAppointment (ParentRecordId = workOrderObj.Id,Status = status,EarliestStartTime =  earlyStart,DueDate = dueDate,ServiceTerritoryId = serviceTerritoryObj.id);
        insert serviceAppointmentObj;
        return serviceAppointmentObj;
    }
    
    public static void createPostRequest(String postURL, ABWrapper.requestWrapper wrapper) {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = postURL;
        req.httpMethod = 'POST';
        
        
        req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
        
        RestContext.request = req;
        RestContext.response= res;
    }
    
    public static ServiceAppointment newSAObj(String Status){
        OperatingHours operatingHour = TestFactory.creatOperatingHours('Eastern Operating Hours Test', 'America/New_York');	
        ServiceTerritory serviceTerritory = TestFactory.creatServiceTerritory('MD', operatingHour, True);
        
        Datetime beforeStartDate = system.Today().addDays(1);	
        Datetime beforeEndDate = system.Today().addDays(3);	
        
        WorkOrder objWorkOrder = new WorkOrder();
        objWorkOrder.StartDate = beforeStartDate;	
        objWorkOrder.EndDate = beforeEndDate;	
        objWorkOrder.State = 'MD';	
        objWorkOrder.ServiceTerritoryId = serviceTerritory.Id;	
        insert objWorkOrder;	
        
        ServiceAppointment serAppointment = TestFactory.createSA(objWorkOrder,Status,datetime.newInstance(2022, 7, 05, 13, 00, 0),datetime.newInstance(2022, 7, 30, 14, 00, 0),serviceTerritory);
        return serAppointment;
    }
    
    public static void createSchedulingPolicy(){
        FSL__Scheduling_Policy__c fslSchedulingPolicy = new FSL__Scheduling_Policy__c();	
        fslSchedulingPolicy.Name = 'Test Scheduling Policy';
        insert fslSchedulingPolicy;	
    }
    
    public static void createOperatingHour(){
        OperatingHours operatingHour = new OperatingHours();	
        operatingHour.Name = 'Test Operating Hour';
        insert operatingHour;	
    }
}