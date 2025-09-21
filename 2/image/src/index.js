const http = require('http');
const port = 3030;
http.createServer((req, res) => {
  console.log(req.url);
  res.end("Hello Node.js Server!");
}).listen(port, err => {
  if (err) return console.error("something bad happened", err);
  console.log('server is listening on port', port);
});
