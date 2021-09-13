var solExplore = require ('sol-explore'),
	solparse = require ('pegjs-solidity');

module.exports = {

	version: require ('./package.json').version,

	findImports: function (sourceCode) {

		var importedFiles = [], AST;

		try {
			AST = solparse.parse (sourceCode);
		} catch (e) {
			throw new Error (
				'An error occured while trying to parse the code:\n' + e
			);
		}

		solExplore.traverse (AST, {

			enter: function (node) {
				if (node.type === 'ImportStatement') {
					importedFiles.push (node.from);
				}
			}

		});

		return importedFiles;

	}

};
