public class EinsteinExampleCtrl {
    
    //Vision API Example - Prediction From URL
    public List<EinsteinMaster.Prediction> getCallVisionUrl() {
        return EinsteinMaster.predictUrl('http://metamind.io/images/generalimage.jpg', 'GeneralImageClassifier');
    }

    //Vision API Example - Prediction From Blob
    public List<EinsteinMaster.Prediction> getCallVisionContent() {
        Attachment atc = [SELECT id,body FROM Attachment where Id = 'YOUR ATTACHMENT ID' LIMIT 1];
        return EinsteinMaster.predictBlob(atc.body, 'GeneralImageClassifier');
    }
    
    //Vision API Example - Prediction From Base64
    public List<EinsteinMaster.Prediction> getCallVisionBase64() {
        //Give Base64 string to below variable : Try this website for convert image on base64 https://www.askapache.com/online-tools/base64-image-converter/
        String base64Str = '';
        return EinsteinMaster.predictBase64(base64Str, 'GeneralImageClassifier');
    }
    
    //Language API Example - Sentiment
    public List<EinsteinMaster.Prediction> getCallSentiment() {
        return EinsteinMaster.sentiment('I love salesforce', 'CommunitySentiment');
    }
    
    //Language API Example - Intent
    public List<EinsteinMaster.Prediction> getCallIntent() {
        return EinsteinMaster.intent('where is my order.', 'PASS YOUR MODEL ID HERE');
    }
}