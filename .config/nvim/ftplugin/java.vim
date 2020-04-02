set sw=4 ts=4 sts=4 expandtab

" run java with F5, don't forget to 'cd' to the file folder directory
map <buffer> <F4> :w<CR>:!if [ -d javabin ]; then javac -d javabin *.java; else echo "directory 'javabin' not found"; fi<CR>
"map <buffer> <F5> :w<CR>:!if [ -d javabin ]; then javac -d javabin '%' && cd javabin && java '%:r'; else echo "directory 'javabin' not found"; fi<CR>
"map <buffer> <F15> :w<CR>:!javac -d javabin '%' && cd javabin && java '%:r' 
map <buffer> <F5> :w<CR>:!javac '%' && java '%:r'<CR>
map <buffer> <F15> :w<CR>:!javac '%' && java '%:r' 

" shortcuts
map <buffer> <Leader>pr oSystem.out.println();<Esc>hi
vmap <buffer> <Leader>pr yoSystem.out.println(<Esc>pA;<Esc>
map <buffer> <Leader>main ipublic static void main(String[] args) {<CR>
map <buffer> <Leader>cls ipublic class<Esc>:put=expand('%:t:r')<CR>kJA {<CR>
map <buffer> <Leader>class ipublic class<Esc>:put=expand('%:t:r')<CR>kJA {<CR>public static void main(String[] args) {<CR>
