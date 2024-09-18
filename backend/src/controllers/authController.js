const models = require('../../database/models/index');
const bcryptjs = require('bcrypt');
const { response } = require('express');
const jsonwebtoken = require('jsonwebtoken');
const env = 'token';
const config = require(__dirname + '/../../database/config/config.json')[env];
const jwtToken = config.jwttoken;

const loginUser = async (req, res) => {
     // const { email, password } = req.body;
     // return res.status(200).json({ email: email, password: password });
     try {
          const { email, password } = req.body;
          const dataUser = await models.User.findOne(
               {
                    where:
                    {
                         email: email
                    }
               }
          );
          // return res.status(200).json({ dataUser: dataUser });
          if (dataUser) {
               const hashedPassword = dataUser.password;
               const passwordMatch = await bcryptjs.compare(password, hashedPassword);
               if (passwordMatch) {
                    const data = {
                         user_ID: dataUser.user_ID,
                         isAdmin: dataUser.isAdmin
                    }
                    const token = await jsonwebtoken.sign(data, jwtToken)
                    return res.status(200).json({ status: true, message: "Login user successfully " , token: token });
                    // return res.status(200).json({ passwordMatch: passwordMatch });
               } else {
                    return res.status(404).json({ status: false, message: "Wrong password. Please try again" });
               }
          } else {
               return res.status(404).json({ status: false, message: "Email not registered. User not found" });
          }
     } catch (error) {
          console.log(error);
          return res.status(500).json({ status: false, message: "Cannot login user", response : error });
     }

}  

module.exports = {
     loginUser 
}