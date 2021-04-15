setlocal sw=2 ts=2 sts=2 expandtab noautoindent

nmap <buffer> <F4> :10 split output:///flutter-dev<CR>
nmap <buffer> <F16> :CocCommand flutter.emulators<CR>

nmap <buffer> <F5> :CocCommand flutter.run<CR>
nmap <buffer> <F17> :CocCommand flutter.dev.quit<CR>

nmap <buffer> <F18> :CocCommand flutter.devices<CR>
