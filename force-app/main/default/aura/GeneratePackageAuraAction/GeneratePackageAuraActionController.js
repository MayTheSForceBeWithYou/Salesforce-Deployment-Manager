({
    initToWinIt : function(component, event, helper) {
        // Call that Apex method to get this package.xml saved!
        let action = component.get('c.attachXmlToDeployment'),
            recordId = component.get('v.recordId');
        action.setParams({
            deploymentId: recordId
        });
        action.setCallback(this, function(response) {
            let closeQuickAction = $A.get("e.force:closeQuickAction"),
                resultsToast = $A.get("e.force:showToast"),
                state = response.getState();
            var toastTitle, toastMessage;
            
            if (state === 'SUCCESS') {
                let retVal = response.getReturnValue();
                toastTitle = 'Success';
                toastMessage = 'Successfully generated package.xml and attached to Deployment.';
            } else {
                let errors = response.getError();
                console.log('State not SUCCESS:', state);
                toastTitle = 'Error';
                toastMessage = 'There was an error generating the package.xml.\n';
                errors.forEach((err) => {
                    toastMessage += err + '\n';
                    console.log(err);
                });
            }
            // Display results in toast
            resultsToast.setParams({
                "title": toastTitle,
                "message": toastMessage
            });
            resultsToast.fire();
            
            closeQuickAction.fire();
        });
        $A.enqueueAction(action);
    }
})
