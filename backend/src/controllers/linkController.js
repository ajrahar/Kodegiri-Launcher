const models = require('../../database/models/index');

// Get all links
const getAllLinks = async (req, res) => {
     try {
          const response = await models.Link.findAll();
          if (response.length === 0) {
               return res.status(404).json({ status: false, message: "Link data not found" });
          }
          res.status(200).json({ status: true, message: "Link data found successfully", response: response});
     } catch (error) {
          console.log("Cannot get all link data : \n", error.message);
          res.status(500).json({ status: false, message: "Cannot get all link data" });
     }
}

// Get link by ID
const getLinksById = async (req, res) => {
     try {
          const response = await models.Link.findOne({
               where: {
                    link_ID: req.params.link_ID
               }
          });
          if (response) {
               return res.status(200).json({status: true, message: "Link data by id found successfully", response: response});
          } else {
               return res.status(404).json({ status: false, message: "Link data by id not found" });
          }
     } catch (error) {
          console.log("Cannot get link data by id : \n", error.message);
          res.status(500).json({ status: false, message: "Cannot get link data by id", response: error.message });
     }
}

// Create new link
const createLinks = async (req, res) => {
     try {
          await models.Link.create(req.body);
          res.status(201).json({ status: true, message: "Link data created successfully", response : req.body });
     } catch (error) {
          console.log("Cannot create new link : \n", error.message);
          res.status(500).json({ status: false, message: "Cannot create new link", response: error.message });
     }
}

// Update link by ID
const UpdateLinks = async (req, res) => {
     try {
          const [updatedRows] = await models.Link.update(req.body, {
               where: {
                    link_ID: req.params.link_ID
               }
          });

          if (updatedRows > 0) {
               return res.status(200).json({ status: true, message: "Link data updated successfully", response: updatedRows    });
          } else {
               return res.status(404).json({ status:false, message: "Link data by id not found" });
          }
     } catch (error) {
          console.log("Cannot update link data : \n", error.message);
          res.status(500).json({ status: false, message: "Cannot update link data", response: error.message });
     }
}

// Delete link by ID
const DeleteLinks = async (req, res) => {
     try {
          const response = await models.Link.destroy({
               where: {
                    link_ID: req.params.link_ID
               }
          });

          if (response > 0) {
               return res.status(200).json({ status: true, message: "Link data deleted successfully", response: response });
          } else {
               return res.status(404).json({ status : false, message: "Link data by id not found" });
          }
     } catch (error) {
          console.log("Cannot delete link data : \n", error.message);
          res.status(500).json({ status: false, message: "Cannot delete link data", response : error.message });
     }
}

module.exports = {
     getAllLinks,
     getLinksById,
     createLinks,
     UpdateLinks,
     DeleteLinks
}
