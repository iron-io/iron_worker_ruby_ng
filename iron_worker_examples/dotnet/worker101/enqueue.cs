using System;
using System.IO;
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web;

abstract
public class EnQueueTask
{
	static public void Main (string[] args)
	{
string project_id = "YOUR_PROJECT_ID";
string token = "YOUR_TOKEN";
string url = "http://worker-aws-us-east-1.iron.io/2/projects/" + project_id + "/tasks";
HttpWebRequest req = WebRequest.Create(new Uri(url))
                     as HttpWebRequest;
req.Method = "POST";
req.ContentType = "application/json";
//setting oauth authorization
req.Headers.Add("Authorization", "OAuth " + token);
string paramz = "{\"tasks\":[{\"code_name\":\"MonoWorker101\",\"payload\":\"{'query':'Heyyaa'}\"},\"delay\":\"5\"]}";

// Encode the parameters as form data:
byte[] formData =
    UTF8Encoding.UTF8.GetBytes(paramz);
req.ContentLength = formData.Length;

// Send the request:
using (Stream post = req.GetRequestStream())
{
  post.Write(formData, 0, formData.Length);
}

// Pick up the response:
string result = null;
using (HttpWebResponse resp = req.GetResponse()
                              as HttpWebResponse)
{
  StreamReader reader =
      new StreamReader(resp.GetResponseStream());
  result = reader.ReadToEnd();
}
}}