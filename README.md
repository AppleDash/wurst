wurst
=====

## About
Wurst is a web application whose job is to accept URLs collected from IRC, download them,
and then make them available in various forms (live, downloaded page/assets, and screenshot.)

## But WTF does it actually do?

It allows API consumers to submit URLs for storage and download, and allows the user to view the live and stored versions of collected URLs in a web UI like this:
![](http://i.imgur.com/BcR6xdM.png)

## API

The API is fairly simple. Simply send a POST to `/api/urls` with `Content-Type: application/json` and content that looks like this:
```javascript
{
  "url": "<http or https url>",
  "time": "<ISO-formatted date and time at which the URL was sent>",
  "server": "<IRC server the URL was sent on>",
  "buffer": "<IRC buffer (channel or PM) name the URL was sent on>",
  "nick": "<IRC nickname of the person who sent the URL>"
}
```

This will return a `url` object that looks something like this:

```javascript
{
  "id": 1, // Unique URL ID
  "title": "<URL title, will be filled>",
  "snippet": "<URL description, will be filled>",
  "processing": true, // Indicates this URL hasn't been fetched yet
  "successful_jobs": [], // Array of successful fetching 'jobs' ran on the URL, initially empty
  "url": "<same as input>",
  "time": "<same as input>",
  "server": "<same as input>",
  "buffer": "<same as input>",
  "nick": "<same as input>"
}
```

The `successful_jobs` array will contain a bunch of strings for each of the 'jobs' run on the URL. A 'job' is something like "detect_content_type", "save_screenshot", or "download_html_page". 

GET to `/api/urls` will return a document that looks like this:

```javascript
{
  "urls": [], // List of URL objects
  "total": 0 // Total number of URLs in the database
}
```

For URLs in the returned array where processing == false, the title, snippet, and successful_jobs fields will be filled in, but title and snippet may be null if none was able to be detected.

This array is paginated. With no parameters, the API returns page 1, with 15 elements per page. This can be modified with the `page` and `per_page` query parameters.

## Naming
```
[1:02 AM] AppleDash: What's a good name for a web thing that captures URLs from IRC and lets me view the live version, a screenshot, and downloaded html/css?
[1:03 AM] Cadey~: spoop
[1:03 AM] Cadey~: because poop
[1:04 AM] AppleDash: lol
[1:04 AM] AppleDash: you're the worst
[1:04 AM] Cadey~: no
[1:04 AM] Cadey~: german sausage jokes are the wurst
[1:05 AM] AppleDash: :(
[1:05 AM] AppleDash: I'm going to name it wurst
```
