'use strict';

const properties = require('../package.json');
const distance = require('../service/distance');

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

var controllers = {
    about: (req, res) => {
        var aboutInfo = {
            author: 'Mihir Singh',
            name: properties.name,
            version: properties.version,
            apiKey: apiKey
        }
        res.json(aboutInfo);
    },

    getDistance: (req, res) => {
        distance.find(req, res, (err, dist) => {
            if (err)
                res.send(err);
            res.json(dist);
        });
    },
};

module.exports = controllers;