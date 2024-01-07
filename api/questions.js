const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async (event) => {
	try {
		// For DEMO purposes only
		console.log(process.env.jwtSecret);

		const params = {
			TableName: "questions",
		};

		const { Items: questions } = await docClient.scan(params).promise();

		return {
			statusCode: 200,
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify({
				error: false,
				questions,
			}),
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
