#!/usr/bin/node

import { execFile as execFileCb } from 'child_process';

function execFile(file, args, options = {}) {
  return new Promise((resolve, reject) => {
    execFileCb(file, args, { encoding: 'utf-8', ...options }, (error, stdout, stderr) => {
      if (error) {
        error.stdout = stdout;
        error.stderr = stderr;
        reject(error);
      } else {
        resolve({
          stdout,
          stderr,
        });
      }
    });
  });
}

async function getAllFiles() {
  const res = await execFile('find', [
    '/',
    '-mount',
    '-type',
    'f',
    '-executable',
  ]);
  
  // console.log('res:', res);
  return res.stdout.trimEnd().split('\n');
}

async function getDeps(file) {
  const res = await execFile('ldd', [file]);

  return res.stdout.trimEnd().split('\n').map(line => {
    // console.log('line:', line);
    const res = line.match(/^\t(.+?)( => (.+))? \(.+\)$/);
    // console.log('regex res:', res);
    if (res) {
      return res[3];
    }
  }).filter(file => file);
}

// const lines = await getDeps('/usr/bin/node');
// console.log('lines:', lines);

const files = {};
let count = 0;
for (const file of (await getAllFiles()).filter(file => !file.startsWith('/usr/src/linux'))) {
  try {
    const deps = await getDeps(file);
    if (file in files) {
      files[file].deps = deps;
    } else {
      files[file] = { deps };
    }
    // console.log({ file, deps });
    for (const dep of deps) {
      if (dep in files) {
        if ('revdeps' in files[dep]) {
          files[dep].revdeps.push(file);
        } else {
          files[dep].revdeps = [file];
        }
      } else {
        files[dep] = { revdeps: [file] };
      }
    }

    count += 1;
    if (count % 100 === 0) {
      console.error(`processed ${count} files`);
    }
  } catch (err) {
    if (err.stderr !== '\tnot a dynamic executable\n') {
      throw err;
    }
  }
  // break;
}

// console.log('files:', files);
console.log(JSON.stringify(files, null, 2));
