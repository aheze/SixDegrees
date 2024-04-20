const { getPath } = require("../utils/pathFinding.js");

const getGraphPath = async (req, res) => {
    console.log(req.body);
    const { source, destination } = req.body;
    try {
        console.log(source);
        const path = await getPath(source, destination);
        if(path == null){
            res.status(200).json({"path":"no path mf"});
        }
        res.status(200).json({"path":path});
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getGraphPath };