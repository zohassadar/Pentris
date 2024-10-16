const fs = require('fs');
const {
    readStripe,
    writeRLE,
    drawRect,
} = require('./nametables');

const [, , param0, param1, drawStats] = process.argv;

if (param0 && param1) {

    var buffer = readStripe(param0);

    writeRLE(
        param1,
        buffer,
    );
}
