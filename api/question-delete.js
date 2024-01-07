const AWS = require("aws-sdk");
const ddb = new AWS.DynamoDB();

module.exports.handler = async (event) => {
	let id;
	if (event.body !== null && typeof event.body !== "undefined") {
		try {
			const json = JSON.parse(event.body);
			id = json.id;
		} catch (err) {
			console.log("JSON Parsing Error");
			console.log(err);
		}
	} else {
		id = event.id !== null ? event.id : "";
	}

	try {
		console.log("Delete " + id);
		await ddb
			.deleteItem({
				Key: { id: { S: id } },
				TableName: "questions",
			})
			.promise();

		return {
			statusCode: 200,
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				error: false,
				id,
			}),
		};
	} catch (err) {
		return {
			statusCode: 500,
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
