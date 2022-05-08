require('dotenv').config();
const request = require('request');

const apiKey = process.env.ZIPCODE_API_KEY;

const zipCodeURL = process.env.ZIPCODE_API_URL;

var distance = {
    find: (req, res, next) => {
        request(zipCodeURL + apiKey +
            '/distance.json/' + req.params.zipcode1 + '/' +
            req.params.zipcode2 + '/mile',
            (error, response, body) => {
                if (!error && response.statusCode == 200) {
                    response = JSON.parse(body);
                    res.send(response);
                } else {
                    console.log(response.statusCode + response.body);
                    res.send({
                        distance: -1
                    });
                }
            });
    }
};

module.exports = distance;