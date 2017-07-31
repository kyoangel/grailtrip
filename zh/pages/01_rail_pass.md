---
layout: page
lang: zh
title: 欧洲铁路通票（Rail Pass）的API接入文档
description: 帮助您搜索、比较、预定欧洲地面交通（铁路、大巴）车票
---

## 概述
相比点对点车票，通票提供了欧洲全境的不限搭乘次数和时间，随上随下，自由旅行的出行方案。本文档描述如何通过API调用来生成通票订单。

通票订单的流程如下(标注*的步骤为必需操作)：
  按国家搜索 -> 预定 -> 确认预定。

通票车票为纸质票，在预定确认后将由后台人工打印通票并快递给预留地址。

## Search PassTickets
传入国家信息，返回通票信息

*HTTP GET*

`/api/v1/pass_solutions?#{params.to_query}`

*Example*

/api/v1/pass_solutions?ctrs%5B%5D=fr&ctrs%5B%5D=de

*Sample Search Result*
```json
{
  "data": {
    "pss": [
      {
        "pcode": "frde08days02month",
        "pname": "02个月任意08天",
        "pdescr": "EURAIL THREE-COUNTRY PASS LEVEL HIGH",
        "pcur": "EUR",
        "frs": [
          {
            "fcode": "frde08days02monthadultfirst",
            "name": "成人一等座",
            "st": "first_class",
            "pt": "adult",
            "tt": "paper",
            "pr": 45800
          },
          {
            "fcode": "frde08days02monthchildfirst",
            "name": "儿童一等座",
            "st": "first_class",
            "pt": "child",
            "tt": "paper",
            "pr": 0
          },
          {
            "fcode": "frde08days02monthadultstandard",
            "name": "成人二等座",
            "st": "second_class",
            "pt": "adult",
            "tt": "paper",
            "pr": 36700
          },
          {
            "fcode": "frde08days02monthchildstandard",
            "name": "儿童二等座",
            "st": "second_class",
            "pt": "child",
            "tt": "paper",
            "pr": 0
          }
        ],
        "ctrs": [
          {
            "cc": 80,
            "cn": "德国"
          },
          {
            "cc": 87,
            "cn": "法国"
          }
        ]
      },
      {
        "pcode": "frde06days02monthyouthonlystandard",
        "pname": "02个月任意06天",
        "pdescr": "EURAIL TWO-COUNTRY STANDARD CLASS YOUTH PASS LEVEL HIGH",
        "pcur": "EUR",
        "frs": [
          {
            "fcode": "frde06days02monthyouthonlystandardyouthstandard",
            "name": "青年二等座",
            "st": "second_class",
            "pt": "youth",
            "tt": "paper",
            "pr": 25800
          }
        ],
        "ctrs": [
          {
            "cc": 87,
            "cn": "法国"
          },
          {
            "cc": 80,
            "cn": "德国"
          }
        ]
      }
    ]
  }
}
```

## Book Pass Tickets

传入票价信息、乘客信息、联系人地址信息就可以预订和确认通票

### Book request
```json
{
      "ct": {
        "name": "sss",
        "e": "qinwen.shi@gmail.com",
        "ph": "13800000000",
        "pos": "201203",
        "add": "Lanhua Road 99"
      },
      "pf": [
        {
          "fc": "atdkdeno05days02monthyouthonlyfirstyouthfirst",
          "plist": [
            {
              "lst": "Shi",
              "fst": "Wen",
              "birth": "2017-01-26",
              "e": "qinwen.shi@gmail.com",
              "ph": "15000367081",
              "passport": "",
              "exp": ""
            }
          ]
        }
      ]
    }
```

### Book Response
```json
{
  "oid": "OF_LO3K5QYVZ",
  "sts": "to_be_confirmed",
  "ols": [
    {
      "amt": 34300,
      "cur": "EUR",
      "fname": "青年一等座",
      "st": "first_class",
      "pt": "youth"
    }
  ]
}
```

### Confirm Request:

只需要根据Book返回的oid构建Confirm的URL，Post到就可以完成订单确认。

p.s. 如果支付宝支付的渠道，需要额外在post参数中加上 `paid = true`。参考：
{% assign pages = site.pages , where:"title", "用支付宝支付GrailTrip订单"%}
{% for page in pages %}
  <li>
      <a class="post-link" href="{{ page.url , prepend: site.baseurl }}">{{ page.title }}</a>
  </li>
{% endfor %}


### Confirm Response

```json
{
  "oid": "OF_LO3K5QYVZ",
  "sts": "confirmed",
  "ols": [
    {
      "amt": 34300,
      "cur": "EUR",
      "fname": "青年一等座",
      "st": "first_class",
      "pt": "youth"
    }
  ]
}
```

### Example
```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

book_information = {
      "ct": {
        "name": "sss",
        "e": "qinwen.shi@gmail.com",
        "ph": "13800000000",
        "pos": "201203",
        "add": "Lanhua Road 99"
      },
      "pf": [
        {
          "fc": "atdkdeno05days02monthyouthonlyfirstyouthfirst",
          "plist": [
            {
              "lst": "Shi",
              "fst": "Wen",
              "birth": "2017-01-26",
              "e": "qinwen.shi@gmail.com",
              "ph": "15000367081",
              "passport": "",
              "exp": ""
            }
          ]
        }
      ]
    }
class Hash

  def to_query(namespace = nil)
    collect do ,key, value,
      unless (value.is_a?(Hash) ,, value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact.sort! * "&"
  end

  alias_method :to_param, :to_query
end

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params)
  sign = Digest::MD5.hexdigest(hashdata.sort.map{,k,v, "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
end

#alpha
api_key = "yourapikey"
secret = "you-secret-key"
env = "alpha"

def send_http_post uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { ,http,
    request = Net::HTTP::Post.new uri
    signature = signature_of(api_key, secret, params.reject {,k, v, v.is_a? Hash}.reject {,k, v, v.is_a? Array}.reject {,k, v, v.nil?})
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    request["Content-Type"] = "application/json"
    request.body = params.to_json

    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  # book
  uri = URI("https://#{env}.api.detie.cn/api/v1/pass_orders")
  resp = send_http_post uri, api_key, secret, book_information
  print resp.to_json
  pass_order_id = resp['oid']
  # confirm
  params = {offline_order_id: pass_order_id}
  uri = URI("https://#{env}.api.detie.cn/api/v1/pass_orders/#{pass_order_id}/pass_confirmations")
  resp = send_http_post uri, api_key, secret, params
  print resp.to_json
rescue =>e
  p e
end
```

### 常用的通票
这里列出常用的通票以及其对应的通票编码
[railway pass code](/data/railpass.csv)

