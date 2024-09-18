const models = require('../../database/models/index');

// Get all links
const getAllLinks = async (req, res) => {
     try {
          const response = await models.Link.findAll();
          if (response.length === 0) {
               return res.status(404).json({ message: "Tidak ada data link ditemukan." });
          }
          res.status(200).json(response);
     } catch (error) {
          console.log("Data link gagal ditemukan : \n", error.message);
          res.status(500).json({ message: "Data link gagal ditemukan" });
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
               return res.status(200).json(response);
          } else {
               return res.status(404).json({ message: "ID data link tidak ditemukan." });
          }
     } catch (error) {
          console.log("Data link gagal ditemukan : \n", error.message);
          res.status(500).json({ message: "Data link gagal ditemukan" });
     }
}

// Create new link
const createLinks = async (req, res) => {
     try {
          await models.Link.create(req.body);
          res.status(201).json({ success: "Data link berhasil dikirim." });
     } catch (error) {
          console.log("Data link gagal dikirim : \n", error.message);
          res.status(500).json({ message: "Data link gagal dikirim" });
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
               return res.status(200).json({ message: "Data link berhasil diupdate." });
          } else {
               return res.status(404).json({ message: "ID data link tidak ditemukan." });
          }
     } catch (error) {
          console.log("Data link gagal diupdate : \n", error.message);
          res.status(500).json({ message: "Data link gagal diupdate" });
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
               return res.status(200).json({ message: "Data link berhasil dihapus." });
          } else {
               return res.status(404).json({ message: "ID data link tidak ditemukan." });
          }
     } catch (error) {
          console.log("Data link gagal dihapus : \n", error.message);
          res.status(500).json({ message: "Data link gagal dihapus" });
     }
}

module.exports = {
     getAllLinks,
     getLinksById,
     createLinks,
     UpdateLinks,
     DeleteLinks
}
