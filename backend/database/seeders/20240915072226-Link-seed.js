'use strict';

const user = require('../models/user');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {

    await queryInterface.bulkInsert('Links', [
      {
        user_ID: user.user_ID,
        title: 'Youtube',
        url: 'https://youtube.com',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        user_ID: user.user_ID,
        title: 'Google',
        url: 'https://google.com',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        user_ID: user.user_ID,
        title: 'Shopee',
        url: 'https://shopee.co.id',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

  },

  async down(queryInterface, Sequelize) {

    await queryInterface.bulkDelete('Links', null, {});

  }
};
