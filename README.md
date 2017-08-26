# Salesforce-Einstein-Custom-Code

This repository contains combined and modified code of multiple files for Salesforce Einstein.
You can see these files here: (Original Resource) 
1. https://github.com/salesforceidentity/jwt 
2. https://github.com/MetaMind/apex-utils


************************************************************************************************
How to use the EinsteinMaster:

1. Predict from Image URL:
      EinsteinMaster.predictUrl('[IMAGE URL]', '[MODEL ID]');
      
2. Predict from Blob Data:
      EinsteinMaster.predictBlob([BLOB DATA], '[MODEL ID]');
      
3. Predict from Base64:
      EinsteinMaster.predictBase64('[BASE64]', '[MODEL ID]');
      
4. Predict for Sentiment:
      EinsteinMaster.sentiment('[STRING]', '[MODEL ID]');
   
5. Predict for Intent:
      EinsteinMaster.intent('[STRING]', '[MODEL ID]');
      
6. Get the Access Token:
      EinsteinMaster.getAccessToken();
      
Note: Change Email ID in EinsteinMaster.apex with you registered email id.
************************************************************************************************
