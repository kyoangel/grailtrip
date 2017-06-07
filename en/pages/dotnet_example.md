---
layout: page
lang: en
title: .NET API consumer example
description: .NET C# API consumer example
---

## Summary
The main purpose of this article is to show you how to encypt the url parameters with MD5, and then get the search result.

## Launguge version and the libraries
.NET Framework 4.6
Json.NET
RestSharp

## Codes

```csharp
using GrailTrip.SDK.Requests;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace GrailTrip.SDK
{
    public class Client
    {
        [Fact]
        public void GetSearch()
        {
            var searchReqeust = new SearchRequest
            {
                StartStationCode = "ST_EZVVG1X5",
                DestinationStationCode = "ST_D8NNN9ZK",
                StartTime = DateTime.Now.AddDays(20),
                NumberOfAdult = 1,
                NumberOfChildren = 0
            };

            var dateTime = DateTime.Now.ToUniversalTime();
            var secure = new ParamSecure(Config.Secret, Config.ApiKey, dateTime, searchReqeust);
            var signature = secure.Sign();

            var client = new RestClient(Config.GrailTripHost);

            var request = new RestRequest($"/api/v1/online_solutions?{searchReqeust.GetURL()}", Method.GET);
            request.AddHeader("From", Config.ApiKey);
            request.AddHeader("Date", dateTime.ToString("r"));
            request.AddHeader("Authorization", signature);

            var response = client.Get(request);
            Console.WriteLine(response.Content);
        }
    }
}

```

How to encrypt the parameters：
```csharp
using GrailTrip.SDK.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;


namespace GrailTrip.SDK
{
    public class ParamSecure
    {
        public ParamSecure(string secret, string apiKey, DateTime datetime, RequestBase request)
        {
            this.Secret = secret;
            this.ApiKey = apiKey;
            this.CurrentTime = datetime;
            this.Request = request;
        }

        public string Secret { get; set; }
        public DateTime CurrentTime { get; set; }
        public RequestBase Request { get; set; }
        public string ApiKey { get; private set; }

        public string Sign()
        {
            var sources = Request.GetSignatureSources();
            sources["api_key"] = this.ApiKey;
            sources["t"] = new DateTimeOffset(CurrentTime).ToUnixTimeSeconds().ToString();
            var sortedSources = new SortedDictionary<string, string>(sources);

            var input = string.Join("", sortedSources.Select(x => string.Format("{0}={1}", x.Key, x.Value)).ToList());

            using (MD5 md5Hash = MD5.Create())
            {
                var data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input + this.Secret));

                var sb = new StringBuilder();

                for (int i = 0; i < data.Length; i++)
                {
                    sb.Append(data[i].ToString("x2"));
                }

                return sb.ToString();
            }
        }
    }
}

```

I abstract one class for the request：
```csharp
using Newtonsoft.Json;
using System;

namespace GrailTrip.SDK.Requests
{
    public class SearchRequest : RequestBase
    {
        [JsonProperty("s")]
        public string StartStationCode { get; set; }

        [JsonProperty("d")]
        public string DestinationStationCode { get; set; }

        [JsonProperty("dt")]
        public string StartTimeString
        {
            get
            {
                return this.StartTime.ToString("yyyy-MM-dd HH:mm");
            }
        }

        [JsonProperty("na")]
        public int NumberOfAdult { get; set; }

        [JsonProperty("nc")]
        public int NumberOfChildren { get; set; }


        public DateTime StartTime { get; set; }
    }
}

```

And the request class has a parent class.
```csharp
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;

namespace GrailTrip.SDK.Requests
{
    public abstract class RequestBase
    {
        public  Dictionary<string, string> GetSignatureSources()
        {
            var dic = new Dictionary<string, string>();
            var properties = this.GetType().GetProperties();
            foreach (var prop in properties)
            {
                var attrs = prop.GetCustomAttributes(true);
                foreach (object attr in attrs)
                {
                    var authAttr = attr as JsonPropertyAttribute;
                    if (authAttr != null)
                    {
                        dic[authAttr.PropertyName] = prop.GetValue(this).ToString();
                    }
                }
            }

            return dic;
        }

        public string GetURL()
        {
            var dic = GetSignatureSources();
            return string.Join("&", dic.Select(x => $"{x.Key}={x.Value}"));
        }

    }
}

```
