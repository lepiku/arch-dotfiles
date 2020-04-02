setlocal sw=2 ts=2 sts=2 expandtab noautoindent

map <buffer> <F4> :10 split output:///flutter-dev<CR>
map <buffer> <F14> :CocCommand flutter.emulators<CR>
map <buffer> <F26> :CocCommand flutter.devices<CR>

map <buffer> <F5> :CocCommand flutter.run<CR>
map <buffer> <F27> :CocCommand flutter.dev.quit<CR>
