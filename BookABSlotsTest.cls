@isTest
public with sharing class BookABSlotsTest {
    
    private static final String BOOK_SLOT_URL = '/services/apexrest/BookABSlots';
    private static User sysAdmin = [SELECT ID, Name FROM USER WHERE Profile.Name = 'System Administrator' AND IsACTIVE = true LIMIT 1];
    
    @isTest
    static void doPostTestWithSANumber(){
        system.runAs(HSTestFactory.UserCreate()) {
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            testWrapper.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.ERROR_MESSAGE);        
    }
    
    @isTest
    static void doPostTestWithoutSANumber(){
        system.runAs(HSTestFactory.UserCreate()) {
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.MISSING_PARAMETER);        
    }
    
    @isTest
    static void doPostTestValidSchedulingPolicy(){
        system.runAs(HSTestFactory.UserCreate()) {
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            testWrapper.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.MISSING_PARAMETER);        
    }
    
    @isTest
    static void doPostTestInValidStatus(){
        system.runAs(HSTestFactory.UserCreate()) {
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Dispatched');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            testWrapper.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.MISSING_PARAMETER);        
    }
    
    @isTest
    static void doPostTestNoSAFound(){
        system.runAs(HSTestFactory.UserCreate()) {
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            testWrapper.serviceAppointmentNumber = 'TestSA';
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.MISSING_PARAMETER);        
    }
    
    @isTest
    static void doPostTestNoSchedulingPolicy(){
        system.runAs(HSTestFactory.UserCreate()) {
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            testWrapper.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.MISSING_PARAMETER);        
    }
    
    @isTest
    static void doPostTestValidStatus(){
        system.runAs(HSTestFactory.UserCreate()) {
            HSTestFactory.createSchedulingPolicy();
            WorkOrder testWO = HSTestFactory.createWorkOrder();
            ServiceAppointment testSA = HSTestFactory.newSAObj('Open');
            
            List<ServiceAppointment> tempObj = [Select id,AppointmentNumber from ServiceAppointment where id =: testSA.Id];
            
            
            ABWrapper.requestWrapper testWrapper = new ABWrapper.requestWrapper();
            testWrapper.serviceAppointmentNumber = tempObj[0].AppointmentNumber;
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,testWrapper);
            
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
        System.assertEquals(MyABUtil.FAILURE_STATUS_CODE, RestContext.response.statusCode,MyABUtil.MISSING_PARAMETER);        
    }

    @isTest 
    static void catchBlock() {
        
        system.runAs(HSTestFactory.UserCreate()) {
            HSTestFactory.createPostRequest(BOOK_SLOT_URL,null);
            Test.startTest();
            BookABSlots.doPost();
            Test.stopTest();
        }
    }
}