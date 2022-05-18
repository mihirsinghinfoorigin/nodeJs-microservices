require('dotenv').config();

const az_identity = require('@azure/identity');
const az_secret = require('@azure/keyvault-secrets');

const credentials = new az_identity.DefaultAzureCredential();
const client = new az_secret.SecretClient('https://zipcodeapikeyvault.vault.azure.net/', credentials);

const request = require('request');

var apiKey = "";
client.getSecret(process.env.ZIPCODE_API_KEY).then(res => {
    apiKey = res.value;
}
).catch(err => { console.log(err);});

const zipCodeURL = process.env.ZIPCODE_API_URL;

var distance = {
    find: (req, res, next) => {
        request(zipCodeURL + apiKey +
            '/distance.json/' + req.params.zipcode1 + '/' +
            req.params.zipcode2 + '/mile',
            (error, response, body) => {
                console.log(apiKey);
                if (!error && apiKey.trim().length > 0 && response.statusCode == 200) {
                    response = JSON.parse(body);
                    res.send(response);
                } else {
                    console.log(response.statusCode + response.body);
                    res.send({
                        distance: -1,
                        apiKey: apiKey
                    });
                }
            });
    }
};

module.exports = distance;