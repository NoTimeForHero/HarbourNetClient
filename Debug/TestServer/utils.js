const wait = (time) => new Promise((resolve) => setTimeout(resolve, time));

const rawParser = (req, res, next) => {
    var chunks = [];
    req.on('data', function(chunk) { 
        chunks.push(chunk)
    });
    req.on('end', function() {
        req.rawBody = Buffer.concat(chunks);
        next();
    });
}

module.exports = { wait, rawParser }