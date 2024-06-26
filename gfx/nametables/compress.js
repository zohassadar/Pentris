const fs = require('fs');
const {
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawAttrs,
    flatLookup,
    drawRect,
} = require('./nametables');

const [, , param0, param1, drawStats] = process.argv;

if (param0 && param1) {

    var buffer = readStripe(param0);

    if (drawStats) {
       
        // U
        drawRect(buffer,1,6,4,3,16)

        // W
        drawRect(buffer,1,9,4,3,64)

        // V
        drawRect(buffer,1,12,4,3,112)

        // T
        drawRect(buffer,1,15,4,3,160)

        // X
        drawRect(buffer,1,18,4,3,208)

        // I
        drawRect(buffer,1,21,4,3,212)



        // J
        drawRect(buffer,9,6,4,3,20)

        // Y1
        drawRect(buffer,9,9,4,3,68)

        // N1
        drawRect(buffer,9,12,4,3,116)

        // F1
        drawRect(buffer,9,15,4,3,164)

        // S
        drawRect(buffer,9,18,4,3,124)

        // Q
        drawRect(buffer,9,21,4,3,28)




        // L
        drawRect(buffer,17,6,4,3,24)

        // Y2
        drawRect(buffer,17,9,4,3,72)

        // N2
        drawRect(buffer,17,12,4,3,120)

        // F2
        drawRect(buffer,17,15,4,3,168)

        // Z
        drawRect(buffer,17,18,4,3,172)

        // P
        drawRect(buffer,17,21,4,3,76)






    }

    writeRLE(
        param1,
        buffer,
    );
}

