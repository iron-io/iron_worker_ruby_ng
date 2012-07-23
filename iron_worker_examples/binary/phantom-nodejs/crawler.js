var phantom, iron_worker;

phantom = require('phantom');

iron_worker = require('iron_worker/lib/client');
client = new iron_worker.Client({config_file: 'iron.json'});

var search_text = 'Pizza';
var url = 'https://maps.google.com/maps?q=' + encodeURI(search_text) + '+near+san+francisco';

phantom.create(function(ph) {
  return ph.createPage(function(page) {
    return page.open(url, function(status) {
      if (status !== 'success') {
        console.log('Unable to access network');
        ph.exit();
      }
      page.evaluate((function() {
        var list = document.querySelectorAll('a.pp-more-content-link'), urls = [], i;
        // limit to 10 records
        for (i = 0; i < list.length && i < 10; i++) {
          urls.push(list[i].href);
        }
        return urls;
      }), function(result) {
        var target_url, i;
        console.log('Data is', result);
        for (i = 0; i < result.length; i++) {
          target_url = result[i];
          // queue personal task for each page
          client.tasks_create('processor', {url: target_url}, {}, function(error, body) {
            return console.log(body);
          });
        }

        return ph.exit();
      });
    });
  });
});
