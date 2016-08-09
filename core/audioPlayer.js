play(audioChannel, path, flags, cb) {
    const self = this;
    
    if(this.currentStream) {
        cb({message: 'error'});
    }
    // Connect
    this.join(audioChannel)
    // Play File
    .then(connection => connection.playArbitraryFFmpeg( ['-i', path].concat(flags) ))
    // Set event handlers
    .then(currentStream => {
        self.currentStream = currentStream; // null
        currentStream.on('end', ()=>{
            self.clean();
        });
        cb(currentStream);
    })
    .catch(err => cb(err))
}