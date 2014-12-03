var version = (process.version).split(".");
if (version[0]!='v0' || version[1]!='10') {
    throw new Error('Wrong node version');
}
