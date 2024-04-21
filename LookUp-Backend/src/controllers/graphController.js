const { getPath } = require("../utils/pathFinding.js");
const { generateGraph, links, visitedPhoneNumbers } = require("../utils/graphCreation.js");

const getGraphPath = async (req, res) => {
    const { source, destination } = req.body;
    try {
        const path = await getPath(source, destination);
        const path2 = await getPath(destination, source);
        if(path == null && path2 == null){
            res.status(200).json({"path":"no path"});
            return;
        }
        if(path == null){
            res.status(200).json({"path":path2.reverse()});
            return;
        }
        res.status(200).json({"path":path});
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const getGraph = async (req, res) => {
    const { phoneNumber, targetDepth } = req.body;
    try {
        const graph = await generateGraph(phoneNumber, targetDepth);
        if(graph == null){
            res.status(200).json({"graph":"no graph"});
        }
        res.status(200).json({"graph":graph});
        links.clear();
        visitedPhoneNumbers.clear();
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getGraphPath, getGraph };