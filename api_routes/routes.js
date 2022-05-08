'use strict';

const controller = require('../controllers/controller').default;

module.exports = (app) => {
app.route('/about').get(controller.about);
app.route('/distance/:zipcode1/:zipcode2').get(controller.getDistance);
}