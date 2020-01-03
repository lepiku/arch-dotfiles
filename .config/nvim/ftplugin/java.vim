set sw=4 ts=4 sts=4 expandtab

" run java with F5, don't forget to 'cd' to the file folder directory
map <F4> :w<CR>:!if [ -d javabin ]; then javac -d javabin *.java; else echo "directory 'javabin' not found"; fi<CR>
map <F5> :w<CR>:!if [ -d javabin ]; then javac -d javabin '%' && cd javabin && java '%:r'; else echo "directory 'javabin' not found"; fi<CR>
map <Leader><F5> :w<CR>:!javac -d javabin '%' && cd javabin && java '%:r' 

" shortcuts
map <Leader>pr oSystem.out.println();<Esc>hi
vmap <Leader>pr yoSystem.out.println(<Esc>pA;<Esc>
map <Leader>main ipublic static void main(String[] args) {<CR>
map <Leader>cls ipublic class<Esc>:put=expand('%:t:r')<CR>kJA {<CR>
map <Leader>class ipublic class<Esc>:put=expand('%:t:r')<CR>kJA {<CR>public static void main(String[] args) {<CR>
