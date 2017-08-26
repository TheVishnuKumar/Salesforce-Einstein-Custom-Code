public class EinsteinMaster{
    //Replace you EMAIL Id here
    public static final String USER_EMAIL = '<Your Email ID>';
    public static string API = 'https://api.einstein.ai/v2';
    
    
    
    /**********WE DONT NEED TO TOUCH ANY CODE BELOW THIS*********/
    public static String LANGUAGE_API = API + '/language';
    public static String SENTIMENT = LANGUAGE_API + '/sentiment';
    public static String INTENT = LANGUAGE_API + '/intent';
    
    public static String VISION_API = API+'/vision';
    public static String PREDICT = VISION_API + '/predict';

    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';

    //JWT Start Here
    public class JWT {
        public String alg {get;set;}
        public String iss {get;set;}
        public String sub {get;set;}
        public String aud {get;set;}
        public String exp {get;set;}
        public String iat {get;set;}
        public Map<String,String> claims {get;set;}
        public Integer validFor {get;set;}
        public String cert {get;set;}
        public String pkcs8 {get;set;}
        public String privateKey {get;set;}

        public JWT(String alg) {
            this.alg = alg;
            this.validFor = 300;
        }

        public String issue() {
            String jwt = '';
        
            JSONGenerator header = JSON.createGenerator(false);
            header.writeStartObject();
            header.writeStringField('alg', this.alg);
            header.writeEndObject();
            String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
                
            JSONGenerator body = JSON.createGenerator(false);
            body.writeStartObject();
            body.writeStringField('iss', this.iss);
            body.writeStringField('sub', this.sub);
            body.writeStringField('aud', this.aud);
            Long rightNow = (dateTime.now().getTime()/1000)+1;
            body.writeNumberField('iat', rightNow);
            body.writeNumberField('exp', (rightNow + validFor));
            if (claims != null) {
                for (String claim : claims.keySet()) {
                    body.writeStringField(claim, claims.get(claim));
                }
            }
            body.writeEndObject();
            
            jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
            
            if ( this.alg == HS256 ) {
                Blob key = EncodingUtil.base64Decode(privateKey);
                Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
                jwt += '.' + base64URLencode(signature);  
            } else if ( this.alg == RS256 ) {
                Blob signature = null;
                
                if (cert != null ) {
                    signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
                } else {
                    Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                    signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKey);
                }
                jwt += '.' + base64URLencode(signature);  
            } else if ( this.alg == NONE ) {
                jwt += '.';
            }
            
            return jwt;
        
        }
    
        public String base64URLencode(Blob input){ 
            String output = encodingUtil.base64Encode(input);
            output = output.replace('+', '-');
            output = output.replace('/', '_');
            while ( output.endsWith('=')){
                output = output.subString(0,output.length()-1);
            }
            return output;
        }
    }
    //JWT Ends Here
    
    
    //Getting Access Token Start here
    public static String getAccessToken() {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        string tokenEndpoint = API+'/oauth2/token';
        String access_token = null;
        
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = USER_EMAIL;
        jwt.aud = tokenEndpoint;
        jwt.exp = '3600';
        
 
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt.issue();
        HttpRequest req = new HttpRequest();                            
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint);
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        Http http = new Http();               
        HTTPResponse res = http.send(req);
        
        if ( res.getStatusCode() == 200 ) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;   
    }
    //Getting Access Token End here
    
    
    //HttpFormBuilder Start here
    //The boundary is alligned so it doesn't produce padding characters when base64 encoded.
    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';

    //Returns the request's content type for multipart/form-data requests.
    public static string GetContentType() {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }

    //Pad the value with spaces until the base64 encoding is no longer padded.
    private static string SafelyPad(
        string value,
        string valueCrLf64,
        string lineBreaks) {
        string valueCrLf = '';
        blob valueCrLfBlob = null;

        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }

        return valueCrLf64;
    }

    //Write a boundary between parameters to the form's body.
    public static string WriteBoundary() {
        string value = '--' + Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);
        return EncodingUtil.base64Encode(valueBlob);
    }

    //Write a boundary at the end of the form's body.
    public static string WriteBoundary(
        EndingType ending) {
        string value = '';

        if (ending == EndingType.Cr) {
            //  The file's base64 was padded with a single '=',
            //  so it was replaced with '\r'. Now we have to
            //  prepend the boundary with '\n' to complete
            //  the line break.
            value += '\n';
        } else if (ending == EndingType.None) {
            //  The file's base64 was not padded at all,
            //  so we have to prepend the boundary with
            //  '\r\n' to create the line break.
            value += '\r\n';
        }
        //  Else:
        //  The file's base64 was padded with a double '=',
        //  so they were replaced with '\r\n'. We don't have to
        //  do anything to the boundary because there's a complete
        //  line break before it.

        value += '--' + Boundary + '--';

        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    //Write a key-value pair to the form's body.
    public static string WriteBodyParameter(
        string key,
        string value) {
        string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        string contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        string content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        string valueCrLf = value + '\r\n';
        blob valueCrLfBlob = blob.valueOf(valueCrLf);
        string valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);

        content += SafelyPad(value, valueCrLf64, '\r\n');

        return content;
    }

    //Helper enum indicating how a file's base64 padding was replaced.
    public enum EndingType {
        Cr,
        CrLf,
        None
    }
    //HttpFormBuilder End Here
    
    //Vision Part Start Here
    public static List<Prediction> predictUrl(String url, String model) {
        return predictInternal(url, model, false);
    }

    public static List<Prediction> predictBase64(String base64String,  String model) {
        return predictInternal(base64String,  model, true);
    }

    public static List<Prediction> predictBlob(blob fileBlob, String model) {
        return predictInternal(EncodingUtil.base64Encode(fileBlob),  model, true);
    }

    private static List<Prediction> predictInternal(String sample, String model, boolean isBase64) {
        String access_token = getAccessToken();
        string contentType = GetContentType();
        //  Compose the form
        string form64 = '';

        form64 += WriteBoundary();
        form64 += WriteBodyParameter('modelId', EncodingUtil.urlEncode(model, 'UTF-8'));
        form64 += WriteBoundary();
        if(isBase64) {
         form64 += WriteBodyParameter('sampleBase64Content', sample);
        } else {
         form64 += WriteBodyParameter('sampleLocation', sample);
        }
        form64 += WriteBoundary(EndingType.CrLf);

        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + access_token);
        httpRequest.setEndpoint(PREDICT);

        Http http = new Http();
        List<Prediction> predictions = new List<Prediction>();
        try {
              HTTPResponse res = http.send(httpRequest);
              if (res.getStatusCode() == 200) {
                  System.JSONParser parser = System.JSON.createParser(res.getBody());
                  while (parser.nextToken() != null) {
                      if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'probabilities')) {
                          parser.nextToken();
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                while (parser.nextToken() != null) {
                                    // Advance to the start object marker to
                                    //  find next probability object.
                                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                        // Read entire probability object
                                        Prediction probability = (Prediction)parser.readValueAs(Prediction.class);
                                        predictions.add(probability);
                                    }
                                }
                            }
                      break;
                      }
                  }
              }
         } catch(System.CalloutException e) {
                System.debug('ERROR:' + e);
         }
         return(predictions);
    }
    //Vision Part End Here
    
    //LANGUAGE Part Start Here
    public static List<Prediction> sentiment(String document, String model) {
        return apiCall(SENTIMENT, document, model);
    }

    public static List<Prediction> intent(String document, String model) {
        return apiCall(INTENT, document, model);
    }
    
    private static List<Prediction> apiCall(String endpoint, String document,  String model) {
        string contentType = GetContentType();
        String access_token = getAccessToken();
        
        //  Compose the form
        string form64 = '';
        form64 += WriteBoundary();
        form64 += WriteBodyParameter('modelId', EncodingUtil.urlEncode(model, 'UTF-8'));
        form64 += WriteBoundary();
        form64 += WriteBodyParameter('document', document);
        form64 += WriteBoundary(null);
        blob formBlob = EncodingUtil.base64Decode(form64);

        string contentLength = string.valueOf(formBlob.size());

        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + access_token);
        httpRequest.setEndpoint(endpoint);

        Http http = new Http();
        List<Prediction> predictions = new List<Prediction>();
        try {
              HTTPResponse res = http.send(httpRequest);
              if (res.getStatusCode() == 200) {
                  System.JSONParser parser = System.JSON.createParser(res.getBody());
                  while (parser.nextToken() != null) {
                      if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'probabilities')) {
                          parser.nextToken();
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                while (parser.nextToken() != null) {
                                    // Advance to the start object marker to
                                    //  find next probability object.
                                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                        // Read entire probability object
                                        Prediction probability = (Prediction)parser.readValueAs(Prediction.class);
                                        predictions.add(probability);
                                    }
                                }
                            }
                      break;
                      }
                  }
              }
         } catch(System.CalloutException e) {
                System.debug('ERROR:' + e);
         }
         return(predictions);
    }

    public class Prediction {
        public String label {get;set;}
        public Double probability {get;set;}
    }
    //LANGUAGE End Start Here
}
