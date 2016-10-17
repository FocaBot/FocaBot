sync {
   default.rsyncssh,
   source="./",
   host="me@26292.s.t4vps.eu",
   exclude = {'.bak' , '.tmp', 'node_modules/', 'bin/', '.*' },
   targetdir="/home/me/FocaBot",
}