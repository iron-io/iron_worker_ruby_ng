var phantom = require('phantom');
var fs = require('fs');
var http = require('http');
var querystring = require('querystring');

var payloadIndex = -1;
process.argv.forEach(function(val, index, array) {
  if (val == "-payload") payloadIndex = index + 1;
});
var payload = JSON.parse(fs.readFileSync(process.argv[payloadIndex]));

console.log("payload:", payload);

var url = payload['url'];
if (!url){
  console.error("No url specified");
  process.exit(1);
}

/*
 * Render page to .png image file
 */
var output = __dirname + '/screenshot.png';

phantom.create(function(ph) {
  // failsafe - exit for no reason after 1 minute
  setTimeout(function () {
    console.error("Something bad happened.");
    ph.exit();
  }, 60000);
  ph.createPage(function(page) {
    page.viewportSize = { width: 800, height: 800 };
    return page.open(url, function(status) {
      if (status !== 'success') {
        console.error('Unable to load the address!');
      } else {
        page.render(output, function(){
          console.log("page rendered to " + output);
          upload_file(output);
        });
      }
    });
  });
});


var upload_file = function(file_name){
  var file_data = fs.readFileSync(file_name);
  var post_data = querystring.stringify({
    'key' : 'd4864bbac09661b4722f6f02ec2e5146',  // api key
    'image': new Buffer(file_data).toString('base64')
  });
  var post_options = {
    host: 'api.imgur.com',
    port: '80',
    path: '/2/upload.json',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': post_data.length
    }
  };
  var post_req = http.request(post_options, function(pres) {
    pres.setEncoding('utf8');
    var response = "";  // this will be the response to the POST
    pres.on('data', function (chunk) {
      response += chunk;
    });
    pres.on('end', function() {
      console.log('Response: ' + response);
      var obj = JSON.parse(response); // imgur answers with json
      var result = obj.upload.links;
      console.dir(result); // this will contain the imgur links (image, imgur page, delete, etc.)
      process.exit();
    });
  });
  // post the data
  post_req.write(post_data);
  post_req.end();
};

