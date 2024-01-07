const fs = require("fs");

module.exports.handler = async (event) => {
	try {
		return {
			statusCode: 200,
			headers: {
				"Content-Type": "text/html",
			},
			body: fs.readFileSync(__dirname + "/index.html", "UTF-8"),
		};
	} catch (err) {
		return {
			statusCode: 200,
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				error: true,
				message: err,
			}),
		};
	}
};
