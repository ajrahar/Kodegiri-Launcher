const { response } = require('express');
const models = require('../../database/models/index');
const bcrypt = require('bcrypt');

// Get all users
const getAllUsers = async (req, res) => {
     try {
          const response = await models.User.findAll({
               where: {
                    isAdmin: false
               }
          });
          if (response.length === 0) {
               return res.status(404).json({ status: false, message: "User data not found" });
          }
          res.status(200).json({ status: true, message: "User data found successfully", response: response });
     } catch (error) {
          console.log("User data not found : \n", error.message);
          res.status(500).json({ status: false, message: "User data not found", response: error.message });
     }
}

// Get user by ID
const getUsersById = async (req, res) => {
     try {
          const response = await models.User.findOne({
               where: {
                    user_ID: req.params.user_ID
               }
          });
          if (response) {
               return res.status(200).json({ status: true, message: "User data by id found successfully", response: response });
          } else {
               return res.status(404).json({ status: false, message: "User data by id not found. Id not found" });
          }
     } catch (error) {
          console.log("User data by id not found : \n", error.message);
          res.status(500).json({ status: false, message: "User data by id not found", response: error.message });
     }
}

// Create new user
const createUsers = async (req, res) => {
     try {
          const { name, email, password } = req.body;
          const hashedPassword = await bcrypt.hash(password, 10);
          const response = await models.User.findOne({
               where: {
                    email: email
               }
          });

          if (response) {
               return res.status(409).json({ status: false, message: "User data already exists" });
          }
          const data = {
               name: name,
               email: email,
               password: hashedPassword,
               isAdmin: 0
          }
          await models.User.create(data);
          res.status(201).json({ status: true, message: "User data created successfully", response: req.body });
     } catch (error) {
          console.log("User data not created : \n", error.message);
          res.status(500).json({ status: false, message: "User data not created", response: error.message });
     }
}

// Update user by ID
const UpdateUsers = async (req, res) => {
     try {
          const { name, email, password } = req.body;
          const hashedPassword = await bcrypt.hash(password, 10);
          const [response] = await models.User.update({ name, email, password: hashedPassword }, {
               where: {
                    user_ID: req.params.user_ID
               }
          });

          if (response > 0) {
               return res.status(200).json({ status: true, message: "User data successfully updated", response: response });
          } else {
               return res.status(404).json({ status: false, message: "User data not found", response: response });
          }
     } catch (error) {
          console.log("User data can't be updated : \n", error.message);
          res.status(500).json({ status: false, message: "User data can't be updated", response: error.message });
     }
}

// Delete user by ID
const DeleteUsers = async (req, res) => {
     try {
          const response = await models.User.destroy({
               where: {
                    user_ID: req.params.user_ID
               }
          });

          if (response > 0) {
               return res.status(200).json({ status: true, message: "User data deleted successfully", response: response });
          } else {
               return res.status(404).json({ status: false, message: "User data by id not found", response: response });
          }
     } catch (error) {
          console.log("User data by id can't be deleted : \n", error.message);
          res.status(500).json({ status: false, message: "User data by id can't be deleted", response: error.message });
     }
}

// Get user by email
const getUsersByEmail = async (req, res) => {
     try {
          const response = await models.User.findOne({
               where: {
                    email: req.params.email
               }
          });
          if (response) {
               return res.status(200).json({ status: true, message: "User data by email found successfully", response: response });
          } else {
               return res.status(404).json({ status: false, message: "User data by email not found", response: response });
          }
     } catch (error) {
          console.log("User data by email not found : \n", error.message);
          res.status(500).json({ status: false, message: "User data by email not found", response: error.message });
     }
}

module.exports = {
     getAllUsers,
     getUsersById,
     createUsers,
     UpdateUsers,
     DeleteUsers,
     getUsersByEmail
}
