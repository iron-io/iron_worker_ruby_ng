var page = require('webpage').create(),
  url = 'https://maps.google.com/maps?q=' + phantom.args[0] + '+near+san+francisco';
console.log("Finding " + phantom.args[0] + " near San Francisco")
console.log('URL: ' + url)

page.open(url, function (status) {
  if (status !== 'success') {
    console.log('Unable to access network');
  } else {
    var results = page.evaluate(function () {
      var list = document.querySelectorAll('span.pp-place-title'), stuffs = [], i;
      for (i = 0; i < list.length; i++) {
        stuffs.push(list[i].innerText);
      }
      return stuffs;
    });
    console.log(results.join('\n'));
  }
  phantom.exit();
});

