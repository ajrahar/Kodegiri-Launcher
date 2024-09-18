'use strict';
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) { 
    const hashedPassword = await bcrypt.hash("admin", 10);
    const clientPassword = await bcrypt.hash("client", 10);

    await queryInterface.bulkInsert('Users', [
      { 
        user_ID: uuidv4(),
        name: 'Admin',
        email: 'admin@gmail.com',
        password: hashedPassword,
        isAdmin: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      { 
        user_ID: uuidv4(),
        name: 'Client',
        email: 'client@gmail.com',
        password: clientPassword,
        isAdmin: 0,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    /**
     * Add commands to revert seed here.
     *
     * Example:
     * await queryInterface.bulkDelete('People', null, {});
     */
  }
};
