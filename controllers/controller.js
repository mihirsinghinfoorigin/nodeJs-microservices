'use strict';

import { name as _name, version as _version } from '../package.json';
import { find } from '../service/distance';

var controllers = {
    about: (req, res) => {
        var aboutInfo = {
            name: _name,
            version: _version,
        }
        res.json(aboutInfo);
    },

    getDistance: (req, res) => {
        find(req, res, (err, dist) => {
            if (err)
                res.send(err);
            res.json(dist);
        });
    },
};

export default controllers;