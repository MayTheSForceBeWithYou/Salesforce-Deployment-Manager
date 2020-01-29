public with sharing class GeneratePackageAura {
    
    @AuraEnabled
    public static void attachXmlToDeployment(Id deploymentId) {
        // Even though this is a void method, the Aura response state
        // should still show ERROR if something goes wrong
        
        // TODO: Should we type check for a deployment object ID?
        List<DeploymentMetadataItem__c> deplMetaItems = [
            SELECT Id, Name, MetadataItem__c, MetadataItem__r.MetadataType__c, MetadataItem__r.Name
            FROM DeploymentMetadataItem__c
            WHERE Deployment__c = :deploymentId
        ];
        System.debug('deplMetaItems: ' + deplMetaItems);
        
        Blob thaBlob = packageXmlBlobFromMetadataItems(deplMetaItems);
        ContentVersion contVers = new ContentVersion(
            Title='package.xml',
            PathOnClient='package.xml',
            VersionData=thaBlob
        );
        insert contVers;
        contVers = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :contVers.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId=contVers.ContentDocumentId,
            LinkedEntityId=deploymentId,
            ShareType='V'
        );
        insert cdl;
    }
    
    public static Blob packageXmlBlobFromMetadataItems(List<DeploymentMetadataItem__c> dmis) {
        // Build envelope
        XmlStreamWriter xsw = new XmlStreamWriter();
        xsw.writeStartDocument('UTF-8', '1.0');
        xsw.writeStartElement(null, 'Package', null);//'http://soap.sforce.com/2006/04/metadata');
        xsw.writeAttribute(null, null, 'xmlns', 'http://soap.sforce.com/2006/04/metadata');
        
        // Build map of type name to list of metadata items
        Map<String, List<DeploymentMetadataItem__c>> dmiMap = new Map<String, List<DeploymentMetadataItem__c>>();
        for (DeploymentMetadataItem__c dmi : dmis) {
            if (!dmiMap.containsKey(dmi.MetadataItem__r.MetadataType__c)) {
                dmiMap.put(dmi.MetadataItem__r.MetadataType__c, new List<DeploymentMetadataItem__c>());
            }
            dmiMap.get(dmi.MetadataItem__r.MetadataType__c).add(dmi);
        }
        
        for (String mdType : dmiMap.keySet()) {
            // <types>
            xsw.writeStartElement(null, 'types', null);
            
            for (DeploymentMetadataItem__c dmi : dmiMap.get(mdType)) {
                // <members>
                xsw.writeStartElement(null, 'members', null);
                xsw.writeCharacters(dmi.MetadataItem__r.Name);
                xsw.writeEndElement();
                // </members>
            }
            // <name>
            xsw.writeStartElement(null, 'name', null);
            xsw.writeCharacters(mdType);
            xsw.writeEndElement();
            // </name>
            
            xsw.writeEndElement();
            // </types>
        }
        
        
        
        xsw.writeEndElement();
        xsw.writeEndDocument();
        String xmlAsString = xsw.getXmlString();
        System.debug('xmlAsString: ' + xmlAsString);
        return Blob.valueOf(xmlAsString);
    }
}