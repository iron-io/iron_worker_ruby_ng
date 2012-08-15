var https = require("https");

function queue_task(project, token, code_name,query) {
    // Build the payload
    var payload = {
        "query": query
    };

    var req_json = {
        "tasks": [{
            "code_name": code_name,
            "payload": JSON.stringify(payload)
        }]
    }

    // Convert the JSON data
    var req_data = JSON.stringify(req_json);

    // Create the request headers
    var headers = {
        'Authorization': 'OAuth ' + token,
        'Content-Type': "application/json"
    };

    // Build config object for https.request
    var endpoint = {
        "host": "worker-aws-us-east-1.iron.io",
        "port": 443,
        "path": "/2/projects/" + project + "/tasks",
        "method": "POST",
        "headers": headers
    };

    var post_req = https.request(endpoint, function(res) {
        console.log("statusCode: ", res.statusCode);

        res.on('data', function(d) {
            process.stdout.write(d);
        });
    });

    post_req.write(req_data)
    post_req.end();

    post_req.on('error', function(e) {
        console.error(e);
    });
}

queue_task("YOUR_PROJECT_ID", "YOURTOKEN", "NodeWorker101","Heyyaa");