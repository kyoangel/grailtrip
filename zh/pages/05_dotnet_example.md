---
layout: page
lang: zh
title: .NET C# API 接口消费示例
description: .NET C# API 接口消费示例
---

## 概述
本示例主要描述了在C#语言中如何进行参数的加解密，进而实现接口调用的目的。
示例接口：search

## 语言版本及所用类库
.NET Framework 4.6
Json.NET
RestSharp

## 代码

```csharp
using GrailTravel.SDK.Requests;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace GrailTravel.SDK
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

            var client = new RestClient(Config.GrailTravelHost);

            var request = new RestRequest($"/api/v2/online_solutions?{searchReqeust.GetURL()}", Method.GET);
            request.AddHeader("From", Config.ApiKey);
            request.AddHeader("Date", dateTime.ToString("r"));
            request.AddHeader("Authorization", signature);

            var response = client.Get(request);
            Console.WriteLine(response.Content);
        }
    }
}

```

加密用的类：
```csharp
using GrailTravel.SDK.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;


namespace GrailTravel.SDK
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

本示例抽象出了一个请求类：
```csharp
using Newtonsoft.Json;
using System;

namespace GrailTravel.SDK.Requests
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

将一些方法写到了基类
```csharp
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;

namespace GrailTravel.SDK.Requests
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
