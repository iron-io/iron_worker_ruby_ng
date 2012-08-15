using System;
using System.IO;
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Linq;

abstract
public class HelloWorld
{
	static public void Main (string[] args)
	{
	//default query value
	string query = "iron";

	//parsing payload
	Dictionary<string,string> values = ParsePayload(args);
	string[] keys = values.Keys.ToArray();

    //scanning params for query
	foreach(string key in keys)
		{
		    if (key=="query") {
		    query = values[key];
		    }
		}
    System.Console.WriteLine("Query = {0}", query);

    //making twitter search query
    string response = PerformRequest("GET","http://search.twitter.com/search.json?q="+query);
    //writing response to file
    File.WriteAllText(@"someText.txt", response);
    //reading response from file
    string text = File.ReadAllText(@"someText.txt");
    System.Console.WriteLine("Contents of WriteText.txt = {0}", text);

	}


	static private Dictionary<string,string> ParsePayload(string[] args){
     int payloadIndex=-1;
     for (var i = 0; i < args.Length; i++)
            {
                Console.WriteLine(args[i]);
                if (args[i]=="-payload")
                 {
                    payloadIndex = i;
                    break;
                 }
            }
     if (payloadIndex == -1)
        {
           Console.WriteLine("Payload is empty");
           Environment.Exit(0);
        }

     if (payloadIndex >= args.Length-1)
        {
            Console.WriteLine("No payload value");
            Environment.Exit(0);
        }

     string json = File.ReadAllText(args[payloadIndex+1]);
     var jss = new JavaScriptSerializer();
     Dictionary<string, string> values = jss.Deserialize<Dictionary<string, string>>(json);
     return values;
	}

	private static string PerformRequest(string method, string url)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.Method = method;
        WebResponse response = request.GetResponse();
        StreamReader reader = new StreamReader(response.GetResponseStream());
        string responseString = reader.ReadToEnd();
        reader.Close();
        return responseString;
    }
}