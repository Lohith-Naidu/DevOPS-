const express = require("express");
const path = require("path");

const app = express();

// FIX: absolute path (IMPORTANT)
app.use(express.static(path.join(__dirname, "public")));

// optional fallback route
app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(3000, () => {
    console.log("Portfolio running on port 3000");
});