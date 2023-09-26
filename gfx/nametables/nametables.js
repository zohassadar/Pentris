/*  

Original Author: Kirjava

Original License:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

const { readFileSync, writeFileSync } = require('fs');
const { konamiComp } = require('./rle');

function strip(_array) {
    const array = [..._array];
    const stripped = [];
    while (array.length) {
        const next = array.splice(0, 35);
        stripped.push(...next.slice(3));
    }
    return stripped;
}

function readStripe(filename) {
    const bin = readFileSync(filename);
    return strip(bin);
}

function writeRLE(filename, buffer) {
    const compressed = Buffer.from(konamiComp(Array.from(buffer)));
    // console.log(`${filename.split('/').pop()} ${buffer.length} -> ${compressed.length}`);
    writeFileSync(filename, compressed);
}

function printNT(buffer, lookup) {
    const chars = [...buffer].map(value => lookup[value] || '__NOWAYNOWAY');
    // console.log(chars.join('').match(/.{32}/g).join('\n'));
}

function drawTiles(buffer, lookup, tiles) {
    [...tiles.trim().split('\n').join('')].forEach((d, i) => {
        if (d !== '#') {
            buffer[i] = lookup.indexOf(d);
        }
    });
}

function drawRect(buffer, x, y, w, h, offset) {
    x += 3;
    const pixel = x+ (y*32);
    for (let i=0;w>i;i++) {
        for (let j=0;h>j;j++) {
            buffer[pixel + i + (j * 32)] = offset+i + (j * 0x10);
        }
    }
}

function drawAttrs(buffer, attrs) {
    const palettes = p => p.trim().match(/.+\n.+$/gm)
        .flatMap(line=>(
            [t,b]=line.split('\n'),
            t.trim().match(r=/../g).map((d,i)=>d+b.trim().match(r)[i])
        ))
        .map(d=>+('0b'+[...d].reverse().map(d=>(+d).toString(2).padStart(2,0)).join``));

    [
        [30 * 32, palettes(attrs[0])],
        [31 * 32, palettes(attrs[1])],
    ].forEach(([index, attributes]) => {
        attributes.forEach((byte, i) => { buffer[i+index] = byte; });
    });
}

function flatLookup(lookup) {
    return lookup.trim().split('\n').map(d=>d.padEnd(16).slice(0, 16)).join('');
}

module.exports = {
    strip,
    readStripe,
    writeRLE,
    printNT,
    drawTiles,
    drawRect,
    drawAttrs,
    flatLookup,
};
