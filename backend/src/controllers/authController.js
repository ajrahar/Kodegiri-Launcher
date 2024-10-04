const models = require('../../database/models/index');
const bcryptjs = require('bcrypt'); 
const jsonwebtoken = require('jsonwebtoken'); 
const jwtToken = process.env.JWT_SECRET;

const loginUser = async (req, res) => { 
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
          if (dataUser) {
               const hashedPassword = dataUser.password;
               const passwordMatch = await bcryptjs.compare(password, hashedPassword);  
               if (passwordMatch) {
                    const data = {
                         user_ID: dataUser.user_ID,
                         name : dataUser.name,
                         email: dataUser.email,
                         isAdmin: dataUser.isAdmin
                    }
                    const token = jsonwebtoken.sign(data, jwtToken)
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