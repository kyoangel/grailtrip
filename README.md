# grailtravel

---
title: 铁路API文档 

language_tabs:
  - json
  - ruby

toc_footers:
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - example_for_book_and_confirm_pass
  - errors
  - ticket_tariff
  - frequently_used_stations
  - rail_pass

search: true
---

# 铁路API文档

## 概述

本文档介绍了GRail API定义以及使用场景和例子。

## Search行程

```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

class Object
  # Alias of <tt>to_s</tt>.
  def to_param
    to_s
  end

  # Converts an object into a string suitable for use as a URL query string,
  # using the given <tt>key</tt> as the param name.
  def to_query(key)
    "#{CGI.escape(key.to_param)}=#{CGI.escape(to_param.to_s)}"
  end
end

class NilClass
  # Returns +self+.
  def to_param
    self
  end
end

class TrueClass
  # Returns +self+.
  def to_param
    self
  end
end

class FalseClass
  # Returns +self+.
  def to_param
    self
  end
end

class Array
  # Calls <tt>to_param</tt> on all its elements and joins the result with
  # slashes. This is used by <tt>url_for</tt> in Action Pack.
  def to_param
    collect(&:to_param).join "/"
  end

  # Converts an array into a string suitable for use as a URL query string,
  # using the given +key+ as the param name.
  #
  #   ['Rails', 'coding'].to_query('hobbies') # => "hobbies%5B%5D=Rails&hobbies%5B%5D=coding"
  def to_query(key)
    prefix = "#{key}[]"

    if empty?
      nil.to_query(prefix)
    else
      collect { |value| value.to_query(prefix) }.join "&"
    end
  end
end

class Hash

  def to_query(namespace = nil)
    collect do |key, value|
      unless (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact.sort! * "&"
  end

  alias_method :to_param, :to_query
end

search_criteria = {"d":"ST_D8NNN9ZK","dt": 11.hours.since(Time.new(2017,4,1)).strftime("%Y-%m-%d %H:%M"),"na":1,"nc":0,"s":"ST_EZVVG1X5"}

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params)
  sign = Digest::MD5.hexdigest(hashdata.sort.map{|k,v| "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
  p result
  result
end

#Alpha
api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
env = "alpha"

def send_http_get uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { |http|
    request = Net::HTTP::Get.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  uri = URI("https://#{env}.api.detie.cn/api/v1/online_solutions?#{search_criteria.to_query}")
  async_resp = send_http_get uri, api_key, secret, search_criteria
  p async_resp
  sleep(3)

  get_result_uri = URI("https://#{env}.api.detie.cn/api/v1/async_results/#{async_resp['async']}")
  50.times do
    sleep(3)
    solutions = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
    p solutions
  end
rescue =>e
  p e
end
 

```

右边的例子展示了搜索2017年2月16日中午12点开始从罗马到米兰火车票形成的Request和Response

<aside class="notice">每个request，都需要提供security params</aside>
<aside class="notice">API会采用异步查询的方式获得结果。</aside>
> 搜索Request

```json
  {
    "s": "ST_EZVVG1X5",
    "d": "ST_D8NNN9ZK",
    "dt": "2017-02-16 12:00",
    "na": 1,
    "nc": 0
  }
```


### HTTP Request

`GET /v1/online_solutions`

该操作为异步调用，真实环境下返回异步查询async_key，再通过GET /v1/async_results/{async_key} 获取真实结果。


### 搜索行程Request  


Parameter | Description | 类型         |
--------- | ----------- | ----------- |
s         | 起始站编码    |  string     |
d         | 终点站编码    |  string     |     
dt        | 出发日期，格式为yyyy-MM-dd HH:mm    |  string     | 
na        | 成年人人数    |  integer     |   
nc        | 儿童人数    |  integer     | 

> 搜索Response，返回结果包括意铁(TI)和法拉利铁路(NTV)的行程

```json
  [
    {
      "rw":"TI", 
      "dt":"2017-02-17", 
      "dur":"02:55",
      "s":"ST_D8NNN9ZK", 
      "d":"ST_EZVVG1X5",
      "sn":"Roma Termini(意大利-罗马火车总站(特米尼))", 
      "dn":"Milano Centrale(意大利-米兰中央总站)",
      "ni":0, 
      "secs":[
        {
          "id":"SC_1CO4FO2",
          "s":"ST_D8NNN9ZK", 
          "d":"ST_EZVVG1X5", 
          "sn":"Roma Termini(意大利-罗马火车总站(特米尼))", 
          "dn":"Milano Centrale(意大利-米兰中央总站)", 
          "offers":[
            {
              "o":"1|1|0|ITA", 
              "od":"全价票", 
              "svcs":[
                {
                  "sa":10, 
                  "p":22000,
                  "sc":"30000|1", 
                  "sd":"30000"
                }, 
                {
                  "sa":41, 
                  "p":12200, 
                  "sc":"30002|1", 
                  "sd":"30002"
                }
              ]
            }
          ],
          "trzs":[
            {
              "trz":"FR 9626", 
              "s":"ST_D8NNN9ZK", 
              "d":"ST_EZVVG1X5", 
              "sn":"Roma Termini(意大利-罗马火车总站(特米尼))", 
              "dn":"Milano Centrale(意大利-米兰中央总站)", 
              "dep":"2017-02-17 12:00", 
              "arr":"2017-02-17 14:55"
            }
          ]
        }  
      ]
  },
  {
      "rw":"NTV", 
      "dt":"2017-02-17", 
      "other information": "more information"
  }
]
  

```

### 搜索行程Response  


Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
rw         | 铁路公司编码    |  string    |     
dt        | 出发日期，格式为yyyy-MM-dd HH:mm    |  string     | 
dur        | 时长，格式为HH:mm    |  string     |   
s         | 起始站编码    |  string     |
sn        | 起点站站名    |  string     |
d         | 终点站编码    |  string     | 
dn        | 终点站站名    |  string     |  
ni        | 换车次数    |  integer     | 
secs      | Sections，行程中的不同车型，详见Sections信息表格    |  array     | 

rw铁路公司编码

铁路公司 | 英文名 | 值         |  
--------- | ----------- | ----------- |
意铁         | Trenitalia    |  TI    | 
德铁         | DbBahn    |  DB     |     
法拉利铁路        | Italo    |  NTV     | 

Section信息
因为不同铁路路线可能涉及车型不同，因此对于不同的车型，Offer/Service是不同的，所以有些铁路公司会把整个行程分成Section，然后Section里面包括相同Offer/Service的列车。

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
id        | Section ID  |  string     | 
s         | 起始站编码    |  string     |
sn        | 起点站站名    |  string     | 
d         | 终点站编码    |  string     | 
dn        | 终点站站名    |  string     |  
offers    | Offer列表，详见Offer表格    |  array     |  
trzs      | 列车列表，详见列车表格    |  array     |  

Offer信息

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
o        | Offer Code  |  string     | 
od         | Offer Description    |  string     |
svcs        | 舱位列表，详见services信息表格    |  array     | 

Service信息

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
sa        | 剩余席位  |  integer     | 
p         | 价格，最小货币单位     |  integer     |
sc        | Service Code    |  string     | 
sd        | Service Description    |  string     | 

列车信息

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
trz       | 车次  |  string     | 
s         | 起始站编码    |  string     |
sn        | 起点站站名    |  string     | 
d         | 终点站编码    |  string     | 
dn        | 终点站站名    |  string     | 
dep       | 出发时间，格式为yyyy-MM-dd HH:mm    |  string     |
arr       | 到达时间，格式为yyyy-MM-dd HH:mm    |  string     |


## Book行程

```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

book_information = {
    "ct":
    {
      "name": "Zhang San",
      "e": "test@email.com",
      "post": "post code",
      "ph": "123456",
      "add": "address"
    },
    "psgs": [
      {
        "lst": "First",
        "fst": "Last",
        "birth": "1996-09-02",
        "e": "test@email.com",
        "ph": "123456",
        "passport": "12121221",
        "exp": "2022-11-03"
      }
    ],
    "secs": [
      {
        "id": "SC_1LECVMF",
        "o": "1|1|0|ITA",
        "st": "30000|1"
      }
    ],
    "res": false
  }

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params.reject {|k, v| v.is_a? Hash}.reject {|k, v| v.is_a? Array}.reject {|k, v| v.nil?})
  sign = Digest::MD5.hexdigest(hashdata.sort.map{|k,v| "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
end

#alpha
api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
env = "alpha"

def send_http_post uri, api_key, secret, params
  res = Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { |http|
    request = Net::HTTP::Post.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    request["content_type"] = 'application/json'
    request.body = params.to_json
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }

end

def send_http_get uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { |http|
    request = Net::HTTP::Get.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  uri = URI("https://#{env}.api.detie.cn/api/v1/online_orders")
  async_resp = send_http_post uri, api_key, secret, book_information
  p async_resp
  sleep(3)

  get_result_uri = URI("https://#{env}.api.detie.cn/api/v1/async_results/#{async_resp['async']}")
  50.times do
    sleep(3)
    book_result = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
    p book_result
  end
rescue =>e
  p e
end


```

右边的例子展示了Book 2017年2月16日中午12点从罗马到米兰的高铁(FR 9626)，Executive舱的Request和Response

<aside class="notice">每个request，都需要提供security params</aside>
<aside class="notice">API会采用异步查询的方式获得结果。</aside>
> Book Request


```json
  {
    "ct":
    {
      "name": "Zhang San",
      "e": "test@email.com",
      "post": "post code",
      "ph": "123456",
      "add": "address"
    },
    "psgs": [
      {
        "lst": "First",
        "fst": "Last",
        "birth": "1996-09-02",
        "e": "test@email.com",
        "ph": "123456",
        "passport": "12121221",
        "exp": "2022-11-03"
      }
    ],
    "secs": [
      {
        "id": "SC_1LECVMF",
        "o": "1|1|0|ITA",
        "st": "30000|1"
      }
    ],
    "res": false
  }

```

### HTTP Request

`POST /v1/online_orders`

该操作为异步调用，真实环境下返回异步查询async_key，再通过GET /v1/async_results/{async_key} 获取真实结果。


### Book行程Request  

订票主要提供三类信息，分别是联系人，旅客信息以及订票信息（包括Section信息, offer code, service code）

Parameter | Description | 类型         |
--------- | ----------- | ----------- |
ct         | 联系人信息，详见联系人信息信息表格    |  contact     |
psgs       | 旅客信息，详见旅客信息列表    |  array     |     
sec        | Segments，行程中的不同车型，详见Segment信息表格    |  array     | 
res       | 是否订座，true or false    |  boolean     |

联系人信息

Parameter | Description | 类型         |
--------- | ----------- | ----------- |
name      | 名字    |  string     |
e         | 邮件    |  string     |     
post      | 邮政编码    |  string     | 
ph        | 电话号码    |  string     | 
add       | 邮寄地址    |  string     | 

旅客信息

Parameter | Description | 类型         |
--------- | ----------- | ----------- |
lst      | 姓，拼音    |  string     |
fst         | 名，拼音    |  string     |     
birth      | 生日，格式为yyyy-MM-dd    |  string     | 
passport        | 护照号    |  string     | 
exp       | 护照截止日期，格式为yyyy-MM-dd    |  string     | 

Sections信息


Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
id        | Section ID  |  string     | 
o         | Offer Code    |  string     |
st        | Service Code    |  string     | 


> Book Response

```json
{
  "id": "OD_37Y7KNM0P",
  "rw": "TI",
  "cuy": "CNY",
  "p": 320576,
  "co": 6412,
  "ta": 323782,
  "pc": 2,
  "dt": "2017-04-01",
  "od": 1490870462,
  "s": "ST_D8NNN9ZK",
  "d": "ST_EZVVG1X5",
  "tks": [
    {
      "id": "TK_54MW7WGXQ",
      "p": 160288,
      "s": "ST_D8NNN9ZK",
      "st": "2017-04-01 11:20",
      "d": "ST_EZVVG1X5",
      "at": "2017-04-01 14:40"
    },
    {
      "id": "TK_V384DYMNW",
      "p": 160288,
      "s": "ST_D8NNN9ZK",
      "st": "2017-04-01 11:20",
      "d": "ST_EZVVG1X5",
      "at": "2017-04-01 14:40"
    }
  ]
}
```

### Book行程Response  


Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
id        | ID    |  string    |  
rw        | 铁路公司编码    |  string    |     
cuy       | 币种，EUR, CNY, HKD等    |  string     | 
p         | 票面价格，最小货币单位     |  integer     |
co        | 佣金金额，最小货币单位   |  integer     |   
ta        | 总价格，最小货币单位   |  integer     |
pc        | 旅客人数   |  integer     |
dt        | 出发日期，格式为yyyy-MM-dd    |  string     | 
od        | 创建日期UNIX时间戳    |  integer     |  
s         | 起始站编码    |  string     |
d         | 终点站编码    |  string     | 
tks       | 车票信息    |  array     | 

车票信息

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
id        | ID          |  string    |  
p         | 票面价格，最小货币单位     |  integer     |
s         | 起始站编码    |  string     |
d         | 终点站编码    |  string     | 
st        | 出发时间，格式为yyyy-MM-dd HH:mm    |  string     | 
dt        | 到达时间，格式为yyyy-MM-dd HH:mm    |  string     | 


## Confirm行程

确认车票有线上车票和线下出票两种方式。线上出票会即时生成在线车票。

*信用卡线上支付*

德国国家铁路局需要提供信用卡支付。通过信用卡支付可以立即出票

```ruby

  def signature_of api_key, secret, params = {}
    time = Time.new.to_i
    hashdata = {api_key: api_key, t: time}.merge(params.reject {|k, v| v.is_a? Hash}.reject {|k, v| v.is_a? Array}.reject {|k, v| v.nil?})
    sign = Digest::MD5.hexdigest(hashdata.sort.map{|k,v| "#{k}=#{v}"}.join + secret)
    result = {
      "From": api_key,
      "Date": Time.at(time).httpdate,
      "Authorization": sign
    }
  end
  
  confirm_information = {
      "online_order_id": "OD_V3G44VG85",
      "card": {
        "cn": "349206776921275",
        "name": "full name",
        "exp": "202002",
        "vn": "1234"
      }
  }
  #alpha
  api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
  secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
  env = "alpha"

  def send_http_post uri, api_key, secret, params
    res = Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') { |http|
      request = Net::HTTP::Post.new uri
      signature = signature_of(api_key, secret, params)
      request["From"]=signature[:From]
      request["Date"]=signature[:Date]
      request["Authorization"]=signature[:Authorization]
      request["content_type"] = 'application/json'
      request.body = params.to_json
      response = http.request request # Net::HTTPResponse object
      async_resp = JSON(response.body)
    }

  end

  def send_http_get uri, api_key, secret, params
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') { |http|
      request = Net::HTTP::Get.new uri
      signature = signature_of(api_key, secret, params)
      request["From"]=signature[:From]
      request["Date"]=signature[:Date]
      request["Authorization"]=signature[:Authorization]
      response = http.request request # Net::HTTPResponse object
      async_resp = JSON(response.body)
    }
  end

  begin
    uri = URI("https://#{env}.api.detie.cn/api/v1/online_confirmationss")
    async_resp = send_http_post uri, api_key, secret, book_information
    p async_resp
    sleep(3)

    get_result_uri = URI("https://#{env}.api.detie.cn/api/v1/async_results/#{async_resp['async']}")
    50.times do
      sleep(3)
      book_result = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
      p book_result
    end
  rescue =>e
    p e
  end
```


**Book之后，需要Confirm Booking，才会正式出票，右边是Request和Response的例子**


>Online Confirm Request

```json
  {
    "online_order_id": "OD_V3G44VG85",
    "card": {
      "cn": "349206776921275",
      "name": "full name",
      "exp": "202002",
      "vn": "1234"
    }
  }
```

*HTTP Request*

`POST /v1/online_orders/{online_order_id}/online_confirmations`

该操作为异步调用，真实环境下返回异步查询async_key，再通过GET /v1/async_results/{async_key} 获取真实结果。

*Confirm Booking Request*

Confirm最主要的是需要online_order_id。如果需要订购德铁车票，需要提供信用卡信息和是否订座信息。只有德铁的车次需要注明是否订座，订座费每人2.5欧元。

Parameter | Description | 类型         |
--------- | ----------- | ----------- |
online_order_id         | Book Response中id字段    |  string     |
card        | 信用卡信息，详见信用卡信息信息表格    |  详见信用卡信息     | 

信用卡信息

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
cn        | 信用卡号          |  string    |  
name         | 信用卡持有人姓名     |  string     |
vn       |    安全码         |  string     |   
exp         | 信用卡截止日期，格式为yyyyMM    |  string     |

> Confirm Response

```json
{
  "id": "OC_X57D2Q79Z",
  "oid": "OD_37Y7KNM0P",
  "cuy": "CNY",
  "p": 320576,
  "co": 6412,
  "ta": 323782,
  "dt": "2017-04-01",
  "od": 1490870470,
  "lns": [
    {
      "id": "OL_49MJV58MD",
      "am": 3206,
      "des": "OTA返佣2%"
    },
    {
      "id": "OL_6JYQROZGW",
      "am": 160288,
      "des": "购票"
    },
    {
      "id": "OL_P0MRR6ZMZ",
      "am": 1603,
      "des": "出票费2.2欧每人"
    }
  ]
}
```

*Confirm Booking Response*

Parameter | Description | 类型         |
--------- | ----------- | ----------- |
id        | ID          |  string    |
oid       | 订单ID      |  string    |
cuy       | 币种，EUR, CNY, HKD等    |  string     | 
p         | 票面价格，最小货币单位     |  integer     |
co        | 佣金金额，最小货币单位   |  integer     |   
ta        | 总价格，最小货币单位   |  integer     |
dt        | 出发日期，格式为yyyy-MM-dd    |  string     | 
od        | 创建日期UNIX时间戳    |  integer     |  
lns       | 费用明细    |  array     | 

费用明细

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
id        | ID          |  string    |  
am        | 费用，最小货币单位     |  integer     |
des       | 备注        |  string     |

## 线下出票

预定德国国家铁路局线下出票，可以通过Offline Confirmation来提交离线订单。

*接口URL*

HTTP POST
`api/v1/offline_confirmation`


> Offline Confirm Request

```json
{
  "data": {
    "token": "BK_MR0Y7QKNJ9DN",
    "card": null
  },
  "api_key": "1dfe8baa121443a594794adf4c337567",
  "t": 1485151578,
  "sign": "09fba8919a52b5e1d89f809bc68cd40b"
}
```

## Security Parameters
所有请求都需要加上如下三个参数到http header中
  
  ```json
  {
    From: "ad53f5806e634e698c0f0f04e628444d", 
    Date:"Mon, 13 Mar 2017 09:29:43 GMT", 
    Authorization: "aafb519dddcb782b9a0e727ffeacf6bc"
  }
  ```

  ```ruby
  def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params)
  sign = Digest::MD5.hexdigest(hashdata.sort.map{|k,v| "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
end
  ```

关于t，api_key，p的生成规则为如下三步：
#### 第一步
  * 其中t表示Date所对应的Unix时间戳
  * api_key是对应的Api Key，
  * p是其他参数，结构体参数data不在加密范围内。

#### 第二步
  按键值排序，按"key=value+私钥"形式拼接成字符串：
  "api_key=dc7949c48889de1acf7d6904add01771p=something
t=784887151b086c98345c24e8c3e218add8d6b3107"
#### 第三步
  最后对此字符串进行md5加密后作为加密值

P.S.为了更加直观展示，上述的request都省去了该security params，实际使用中，需要加到HTTP header。

## 异步获取结果
请求结果皆为异步返回，返回方式有2种：
### 1. 通过HTTP Get轮询获取异步结果
例如：/api/v1/async_results/218c2825aaa29fdee42de4ca9dcdcde6
会返回JSON格式的请求结果。

### 2. API通过Webhook的方式推送结果
联系工作人员添加回调的URL，该URL接受跨域的HTTP POST请求，
请求的格式类似，收到请求后该URL返回200，系统停止重新发送。
```json
{
  key: "a0ec87ee69b8baf72073a5354f48e7d4"
  result: [
    {
      "rw": "DB",
      "dt": "2017-02-23",
      "dur": "01:28",
      "s": "ST_E020P6M4",
      "d": "ST_DQMOQ7GW",
      "sn": "Berlin Hbf (tief)",
      "dn": "Halle(Saale)Hbf",
      "ni": 0,
      "secs": [
        {
          "id": "SC_14B0J2P",
          "s": "ST_E020P6M4",
          "d": "ST_DQMOQ7GW",
          "sn": "Berlin Hbf (tief)",
          "dn": "Halle(Saale)Hbf",
          "offers": [
            
            {
              "o": "80003",
              "od": "Flexpreis",
              "svcs": [
                {
                  "sa": 999,
                  "p": 4800,
                  "sc": "",
                  "sd": "2nd Class(2)"
                },
                {
                  "sa": 999,
                  "p": 8000,
                  "sc": "8030001",
                  "sd": "一等座"
                }
              ]
            }
          ],
          "trzs": [
            {
              "trz": "ICE 1730",
              "s": "ST_E020P6M4",
              "d": "ST_DQMOQ7GW",
              "sn": "Berlin Hbf (tief)",
              "dn": "Halle(Saale)Hbf",
              "dep": "2017-02-23 12:02",
              "arr": "2017-02-23 13:30"
            }
          ]
        }
      ]
    }
  ]
}
```
