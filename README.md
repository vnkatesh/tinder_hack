####Personal notes and blogpost here
http://blog.venkatesh.ca/automating-tinder

####Technical documentation & bugs below
1. Facebook authentication doesn't seem to be used anywhere. Calling *https://api.gotinder.com/auth* with the Facebook token seems to return with 'failure validating'. But other requests still seem to work. I'm not sure about this.
1. I accidentally committed my x-auth-token before. Don't worry, I've removed it and reset my account :)
1. Not newbie friendly. You might have to understand the code if you ever plan on running this.
1. Not my best code, coding effort was less than 5 hours in total, definitely would have a lot of bugs if you look for them. This is just proof-of-concept.
1. Use [mitmproxy](http://mitmproxy.org/) to capture initial X-Auth-Token and ETAG/If-Modified-Since. A great tutorial on mitmproxy is [here](http://blog.philippheckel.com/2013/07/01/how-to-use-mitmproxy-to-read-and-modify-https-traffic-of-your-phone/)
