const { convert } = require("tsconfig-to-swcconfig");
const [tsconfig] = process.argv.slice(2);
console.log(JSON.stringify(convert(tsconfig), undefined, 2));
