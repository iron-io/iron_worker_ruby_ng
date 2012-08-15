var http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs"),
    events = require("events"),
    sys = require("util");

var Twitter = (function () {
    var eventEmitter = new events.EventEmitter();

    return {
        EventEmitter:eventEmitter  // The event broadcaster
    };
})();

function get_tweets(query) {
    // Send a search request to Twitter
    var request = http.request({
        host:"search.twitter.com",
        port:80,
        method:"GET",
        path:"/search.json?since_id=" + Twitter.latestTweet + "result_type=recent&rpp=5&q=" + query
    })
        .on("response", function (response) {
            var body = "";
            response.on("data", function (data) {
                body += data;
                try {
                    var tweets = JSON.parse(body);
                    if (tweets.results.length > 0) {
                        Twitter.EventEmitter.emit("tweets", tweets);
                    }
                    Twitter.EventEmitter.removeAllListeners("tweets");
                }
                catch (ex) {
                    console.log("waiting more data...");
                }
            });
        });
    request.end();
}
//putting tweets to log
Twitter.EventEmitter.once("tweets", function (tweets) {
    console.log(JSON.stringify(tweets));
});

//writing to file
Twitter.EventEmitter.once("tweets", function (tweets) {
    var fs = require('fs');
    console.log('Writing to file');
    fs.open('tweets.txt', 'a', 777, function (e, id) {
        fs.write(id, JSON.stringify(tweets), null, 'utf8', function () {
            fs.close(id, function () {
                console.log('file closed');
            });
        });
    });
});

//parse payload and make a search
require('./lib/payload_parser').parse_payload(process.argv, function (payload) {
    query = 'iron.io';
    if (payload && payload['query']) {
        query = payload['query'];
    }
    get_tweets(query);
    console.log('Query:' + query);
});
