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


function konamiComp(buffer) {
    const compressed = [];

    for (let i = 0; i < buffer.length;) {
        const byte = buffer[i];

        // count extra dupes
        let peek = 0;
        for (;byte ==buffer[i+1+peek];peek++);
        const count = Math.min(peek + 1, 0x80);

        if (peek > 0) {
            compressed.push([count, byte]);
            i+= count;
        } else {
            // we have already peeked the next byte and know it's not a double
            // so start checking from there
            const start = i + 1;
            const nextDouble = buffer.slice(start, start + 0x7F)
                .findIndex((d,i,a)=>d==a[i+1]);

            const count = Math.min(nextDouble === -1
                ? buffer.length - i
                : nextDouble + 1, 0x7F);

            compressed.push([0x80 + count, buffer.slice(i, count + i)]);
            i += count;
        }
    }

    compressed.push(0xFF);

    return compressed.flat(Infinity);
}

function strip(_array) {
    const array = [..._array];
    const stripped = [];
    while (array.length) {
        const next = array.splice(0, 35);
        stripped.push(...next.slice(3));
    }
    return stripped;
}

module.exports = function (buffer) {
    const array = Array.from(buffer);
    const compressed = konamiComp(strip(array));
    console.log(`compressed ${buffer.length} -> ${compressed.length}`);
    return Buffer.from(compressed);
};

Object.assign(module.exports, { konamiComp });
