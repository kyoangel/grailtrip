---
layout: page
lang: en
title: Grail API Document
description: Grail API Document
---

# Grail API Document

## Introduction
This article explains the APIs of Grail and how to use them to Search, Book and Confirm tickets of Europe Railways (DB Deutsche Bahn, Trenitalia, Italo) and buses (flixbus).

You only need four APIs to accomplish the very basic ticket search and booking scenario including Search, Book, Confirm, Download.

## Search for Journey Solutions

The following is the request and response message for search journey from 12:00 pm local time, on Feb. 16, 2017, from Roma Termini to Milano Centrale station.

> Make sure provide security params with each request

> Use async query to retrieve the response.

### Search Request

`GET /v1/online_solutions`

This is an async call, an async-key will be returned. Try to use

`GET /v1/async_results/{async_key}` 

to retrieve response data.


Next is request json for a search request for an adult traveler, from 12:00 pm on Feb. 16, 2017, departures from Roma Termini (central station of Roma, station code: 'ST_EZVVG1X5') and arrives in Milano Centrale (station code: ST_D8NNN9ZK).

```json
  {
    "s": "ST_EZVVG1X5",
    "d": "ST_D8NNN9ZK",
    "dt": "2017-02-16 12:00",
    "na": 1,
    "nc": 0
  }
```

#### Parameters
Parameter | Description | Type         |
--------- | ----------- | ----------- |
s         | Departure station code    |  string     |
d         | Destination station code    |  string     |     
dt        | Departure date time，format as yyyy-MM-dd HH:mm    |  string     | 
na        | Number of adults    |  integer     |   
nc        | Number of children      |  integer     | 

The response json message include data of both Trenitalia (TI) and Italo (NTV) because there are two railway companies have trains between Roma and Milano.


### Search Response  
The following is response json for a search request from Roma Termini to Milano Centrale
```json
  [
    {
      "rw":"TI", 
      "dt":"2017-02-17", 
      "dur":"02:55",
      "s":"ST_D8NNN9ZK", 
      "d":"ST_EZVVG1X5",
      "sn":"Roma Termini", 
      "dn":"Milano Centrale",
      "res":"N/A",
      "ni":0, 
      "secs":[
        {
          "id":"SC_1CO4FO2",
          "s":"ST_D8NNN9ZK", 
          "d":"ST_EZVVG1X5", 
          "sn":"Roma Termini", 
          "dn":"Milano Centrale", 
          "offers":[
            {
              "o":"1|1|0|ITA", 
              "od":"Base", 
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
              "sn":"Roma Termini", 
              "dn":"Milano Centrale", 
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
#### Parameters

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
rw         | Railway code    |  string    |     
dt        | Departure date time, format: yyyy-MM-dd HH:mm    |  string     | 
dur        | duration，format: HH:mm    |  string     |   
s         | Departure station code    |  string     |
sn        | Departure station name    |  string     |
d         | Destination station code    |  string     | 
dn        | Destination station name    |  string     |  
res       | Seat reservation      | enum mandatory, optional, N/A      |
ni        | Number of changes    |  integer     | 
secs      | Sections， based on different types of trains, for details see Section information    |  array     | 

**rw Railway Code**

Railway | Name | Value         |  
--------- | ----------- | ----------- |
Italy         | Trenitalia    |  TI    | 
Germany         | DbBahn    |  DB     |     
Italy        | Italo    |  NTV     | 

**Section**
Because different railway companies have different kinds of trains, and the offer and service (coach class), many railway companies split the entire journey solutions into multiple sections and for each section, the offers and services are the same.
Parameter | Description | Type         |  
--------- | ----------- | ----------- |
id        | Section ID  |  string     | 
s         | Departure station code    |  string     |
sn        | Departure station name    |  string     | 
d         | Destination station code    |  string     | 
dn        | Destination station name    |  string     |  
offers    | Offer list    |  array     |  
trzs      | Train list    |  array     |  

**Offer**
Railway companies have different discount for their tickets, it is called Offer.

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
o        | Offer Code  |  string     | 
od         | Offer Description    |  string     |
svcs        | Services list, see service table    |  array     | 

**Service**
Trains have different coach classes, we call it Service.

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
sa        | Seats available  |  integer     | 
p         | Price (in cents)     |  integer     |
sc        | Service Code    |  string     | 
sd        | Service Description    |  string     | 

**Train**

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
trz       | Train code  |  string     | 
s         | Departure station code    |  string     |
sn        | Departure station name    |  string     | 
d         | Destination station code    |  string     | 
dn        | Destination station name    |  string     | 
dep       | Departure date time, format: yyyy-MM-dd HH:mm    |  string     |
arr       | Arrival date time, format: :yyyy-MM-dd HH:mm    |  string     |


The following is sample code to search for journey solutions from both Trenitalia and Italo for an adult traveler, on April 1st, 2017, from Roma Termini to Milano Centrale

> Ruby
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

search_criteria = {"s":"ST_EZVVG1X5","d":"ST_D8NNN9ZK","dt": 11.hours.since(Time.new(2017,4,1)).strftime("%Y-%m-%d %H:%M"),"na":1,"nc":0}

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


## Book

> Make sure provide security params with each request

> Use async query to retrieve the response.

### Book Request

`POST /v1/online_orders`

This is an async call, an async-key will be returned. Try to use

`GET /v1/async_results/{async_key}`
to retrieve response data.

The following is book request json for a ticket for train FR 9626 from Roma to Milano, Executive service, base offer

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

#### Book parameters  

In order to book ticket, we need three kinds of information including contact person, travelers information and order information such as section data, offer code and service code.

Parameter | Description | Type         |
--------- | ----------- | ----------- |
ct         | Contact information, see Contact table    |  contact     |
psgs       | Traveler information, see Traveler table    |  array     |     
sec        | Section information, see Section table    |  array     | 
res       | Flag for seat reservation, DB only    |  boolean     |

**Contact**

Parameter | Description | Type         |
--------- | ----------- | ----------- |
name      | Name    |  string     |
e         | Email    |  string     |     
post      | Post code    |  string     | 
ph        | Phone number    |  string     | 
add       | Mailing address    |  string     | 

**Traveler**

Parameter | Description | Type         |
--------- | ----------- | ----------- |
lst      | Last name    |  string     |
fst         | First name    |  string     |     
birth      | Birthday, format: yyyy-MM-dd    |  string     | 
pt        | Passport number    |  string     | 
exp       | Expiration date of Passport, Format: yyyy-MM-dd    |  string     | 

**Sections**

Parameter | Description | 类型         |  
--------- | ----------- | ----------- |
id        | Section ID  |  string     | 
o         | Offer Code    |  string     |
st        | Service Code    |  string     | 

### Book Response
The following is response json for the book request above.
```json
{
  "id": "OD_37Y7KNM0P",
  "rw": "TI",
  "cuy": "CNY",
  "p": 320576,
  "co": 6412,
  "ta": 323782,
  "dt": "2017-04-01",
  "od": 1490870462,
  "s": "ST_D8NNN9ZK",
  "d": "ST_EZVVG1X5",
  "psgs": [
    {
      "id": "PN_53Y1DDMKX",
      "fst": "firste",
      "lst": "last",
      "birth": "1975-04-01",
      "e": "aoe@oeu.com",
      "ph": "10080",
      "pt": "123456",
      "exp": "2017-04-06"
    }
  ],
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
  ],
  "lns": [
    {
      "id": "OL_PKYKJ5PMQ",
      "am": 1472,
      "at": "slave",
      "lt": "debit",
      "cg": "custom",
      "tg": "TK_V38441V8N",
      "des": "OTA Commission 2%"
    },
    {
      "id": "OL_54MWZ6XMP",
      "am": 73587,
      "at": "master",
      "lt": "credit",
      "cg": "custom",
      "tg": "TK_V38441V8N",
      "des": "Order"
    },
    {
      "id": "OL_LOMO3EOGV",
      "am": 1603,
      "at": "master",
      "lt": "credit",
      "cg": "custom",
      "tg": "PN_53Y1DDMKX",
      "des": "Ticketing fee 2.2 Euro"
    }
  ]
}
```
#### Parameters

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
id        | ID    |  string    |  
rw        | Railway code    |  string    |     
cuy       | Currency, EUR,CNY or HKD etc.    |  string     | 
p         | Ticket price in cents     |  integer     |
co        | Commission in cents   |  integer     |   
ta        | Full price in cents   |  integer     |
dt        | Departure date, format: yyyy-MM-dd    |  string     | 
od        | Order date    |  integer     |  
s         | Departure station code    |  string     |
d         | Destination station code    |  string     | 
psgs      | List of travelers    | array      |
tks       | List of tickets    |  array     | 
lns       | List of fee    | array      |

**Traveler**

Parameter | Description | Type         |
--------- | ----------- | ----------- |
id       | ID          | string      |
lst      | Last name    |  string     |
fst         | First name    |  string     |     
birth      | Birthday, format: yyyy-MM-dd    |  string     | 
ph        | Phone     | string |
e         | Email       | string |
pt        | Passport    |  string     | 
exp       | Expiration date of passport, Format: yyyy-MM-dd    |  string     | 

**Ticket**

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
id        | ID          |  string    |  
p         | Ticket price in cents    |  integer     |
s         | Departure station code    |  string     |
d         | Destination station code    |  string     | 
st        | Departure date time, format: yyyy-MM-dd HH:mm    |  string     | 
dt        | Arrival date time, format: yyyy-MM-dd HH:mm    |  string     | 

**Fee**

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
id        | ID          |  string    |  
am        | Cost in cents     |  integer     |
at        | Account type, master, slave, credit_card| string|
lt        | debit or credit |   string |
cg        | Type     | string      |
tg        | 对应id      | string      |
des       | 备注        |  string     |

The following is ruby sample code for above book request.

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


## Confirm Booking


Please make sure confirm booking within 30 mins after booking, then the ticket will be issued.

> Make sure provide security params with each request

> Use async query to retrieve the response.

### Confirm Request

`POST /v1/online_orders/{online_order_id}/online_confirmations`

This is an async call, an async-key will be returned. Try to use

`GET /v1/async_results/{async_key}` 

to retrieve response data.

The following is Request json for the booking above
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
The most important parameter is online_order_id. If booking Db ticket, please provide credit card and whether to reserve seat. Only DB needs to specify whether to reserve a seat and the servation fee is 2.5 euro per seat.

#### Parameters
Parameter | Description | Type         |
--------- | ----------- | ----------- |
online_order_id         | Id in Book Response json    |  string     |
card        | Credit card information    |  Credit card     | 

**Credit Card**

Parameter | Description | Type         |  
--------- | ----------- | ----------- |
cn        | Card number          |  string    |  
name         | Name     |  string     |
vn       |    Security code         |  string     |   
exp         | Expiration date, format:yyyyMM    |  string     |

### Confirm Response

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
      "des": "OTA Commission 2%"
    },
    {
      "id": "OL_6JYQROZGW",
      "am": 160288,
      "des": "Order"
    },
    {
      "id": "OL_P0MRR6ZMZ",
      "am": 1603,
      "des": "Ticketing fee 2.2 euro per traveler"
    }
  ]
}
```
#### Parameters
Parameter | Description | Type         |
--------- | ----------- | ----------- |
id        | ID          |  string    |
oid       | Order ID      |  string    |
cuy       | Currency, EUR, CNY or HKD    |  string     | 
p         | Ticket price in cents     |  integer     |
co        | Commission in cents   |  integer     |   
ta        | Total price in cents   |  integer     |
dt        | Departure date, format: yyyy-MM-dd    |  string     | 
od        | Order date    |  integer     |  
lns       | List of costs    |  array     | 


### Offline Tickets
Due to DB policy, we have to use offline confirm to book DB train tickets.

**接口URL** 

`api/v1/offline_confirmation`

Request json for offline booking

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


### Online Confirm of DB with Payment with Credit Card
DB requries payment with credit card. Travel will receive ticket right after making payment with credit card.

```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

confirm_information = {
    "online_order_id": "OD_V3G44VG85",
    "card": {
      "cn": "349206776921275",
      "name": "full name",
      "exp": "202002",
      "vn": "1234"
    }
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
### Download Ticket Request

`Get /v1/online_orders/{online_order_id}/online_tickets`

This is a sync call, it will return urls of tickets.

The following example is a download request json
```json
  {
    "online_order_id": "OC_LOEON67VG"
  }

```
The only parameter is online_order_id.


#### Parameters
Parameter | Description | Type         |
--------- | ----------- | ----------- |
online_order_id         | Online Order ID    |  string     |

### Download Ticket Response

```json
{
  
  [
    "http://ticketsdev.ul-e.com/tickets/test1.pdf",
    "http://ticketsdev.ul-e.com/tickets/test2.pdf"    
  ]
}
```

## Security Parameters
Security parameters are required for all requests in http header.
  
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

Three steps to generate t, api_key and p
#### Step 1
  * t is Unix timestamp
  * api_key is API Key we sent to you
  * p is for other parameters. 
  * Data is not part of md5 encryption

#### Step 2
  Concatenate according to 'key=value+private key' into string:
  "api_key=dc7949c48889de1acf7d6904add01771p=something
t=784887151b086c98345c24e8c3e218add8d6b3107"
#### Step 3
  Encrypt with md5

P.S.To simply the request information, all security paramewters of request example are ignored. 

## Retrieve response data with Async call
All response data is retrieve asynch. There are two ways to retrieve:
### 1. Query with HTTP Get

`/api/v1/async_results/218c2825aaa29fdee42de4ca9dcdcde6`

218c2825aaa29fdee42de4ca9dcdcde6 is the async_key returned when posting Search/Book/Confirm

You will receive json format response data once we received response from railway companies. 

### 2. Webhook
Contact admin or send email to oulu@ul-e.com to add your call back url. Please make sure this url accept cross-domain HTTP Post.

The format of request is similar. Once received request, the url will return 200 and system will not send any longer.

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

