using System;
using System.IO;
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web;

abstract
public class EnqueueTask
{
    static public void Main (string[] args)
    {
        string project_id = "YOUR_PROJECT_ID";
        string token = "YOUR_TOKEN";
        string url = "http://worker-aws-us-east-1.iron.io/2/projects/" + project_id + "/tasks";
        var req = WebRequest.Create(new Uri(url)) as HttpWebRequest;
        req.Method = "POST";
        req.ContentType = "application/json";
        //setting oauth authorization
        req.Headers.Add("Authorization", "OAuth " + token);
        var paramz = "{\"tasks\":[{\"code_name\":\"hello\",\"payload\":\"{'query':'xbox'}\"}],\"delay\":\"5\"}";

        // Encode the parameters as form data:
        var formData = UTF8Encoding.UTF8.GetBytes(paramz);
        req.ContentLength = formData.Length;

        // Send the request:
        using (var post = req.GetRequestStream())
        {
            post.Write(formData, 0, formData.Length);
        }

        // Pick up the response:
        string result = null;
        using (var resp = req.GetResponse() as HttpWebResponse)
        {
            StreamReader reader = new StreamReader(resp.GetResponseStream());
            result = reader.ReadToEnd();
        }
    }
}
