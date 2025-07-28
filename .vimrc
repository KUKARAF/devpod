syntax on

set nocompatible
filetype plugin on


let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': 'md'}]


if !executable('aider')
    echohl WarningMsg
    echo "Warning: 'aider' command not found. The Aider command will not work."
    echohl None
endif

if !executable('llm') && !executable('ask')
    echohl WarningMsg
    echo "Warning: Neither 'llm' nor 'ask' command found. The Ask command will not work."
    echohl None
endif

" Create autocmd group for terminal handling
augroup terminal_handling
    autocmd!
augroup END

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
  nnoremap <leader>a :Ag<CR>
endif
set number
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[
nmap <leader>E :exec 'r!'.getline('.')<CR>

set rtp+=~/.fzf
nnoremap <silent> <Leader>b :call fzf#run(fzf#wrap({'source': map(range(1, bufnr('$')), 'bufname(v:val)'), 'sink': 'buffer'}))<CR>
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
nnoremap <silent> <leader>t :Files<CR>
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>l :bnext<CR>
"  nnoremap <silent> <leader>h :bprevious<CR>
"  nnoremap <silent> <leader>l :bnext<CR>
function! AskQuestion(question)
    " Get the current buffer content
    let buffer_content = join(getline(1, '$'), "\n")

    " Create a temporary file to store the buffer content
    let temp_file = tempname()
    call writefile(split(buffer_content, "\n"), temp_file)

    " Determine which command to use
    let cmd = executable('llm') ? 'llm' : 'ask'
    
    " Run the command with the buffer content and question
    let command = cmd . " -s '" . a:question . "' < " . temp_file
    let output = system(command)

    " Open a new tab and display the output
    tabnew
    put =output

    " Delete the temporary file
    call delete(temp_file)
endfunction

function! AiderCommand(...)
    if a:0 == 0
        " No arguments provided, use fzf for buffer selection
        let buffer_list = map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)')
        call fzf#run({
            \ 'source': buffer_list,
            \ 'sink*': {files -> AiderWithFiles(files)},
            \ 'options': '--multi --reverse'
            \ })
        return
    elseif a:1 == '%'
        let file_list = expand('%')
    elseif a:1 == 'buffers' || a:1 == 'b'
        let file_list = join(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'), ' ')
    else
        echo "Invalid scope. Use no arguments for fzf selection, '%' for current file, 'buffers' or 'b' for all files in the buffer."
        return
    endif
    
    " Open terminal with aider
    let cmd = 'aider ' . file_list
    let buf = term_start(cmd, {'term_rows': &lines, 'term_cols': &columns, 'vertical': 0, 'exit_cb': {->execute(['bd!', 'bufdo e!'])}})
    " Switch to terminal mode
    startinsert
endfunction

function! AiderWithFiles(files)
    let file_list = join(a:files, ' ')
    let cmd = 'aider ' . file_list
    let buf = term_start(cmd, {'term_rows': &lines, 'term_cols': &columns, 'vertical': 0, 'exit_cb': {->execute(['bd!', 'bufdo e!'])}})
    startinsert
endfunction

function! ExecuteVisualSelection()
    " Get the visually selected text
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return
    endif
    " Handle partial line selections
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let selected_text = join(lines, "\n")
    
    " Expand % to current file path
    let expanded_text = substitute(selected_text, '%', expand('%'), 'g')
    
    " Execute the command and get output
    let output = system(expanded_text)
    " Remove trailing newline if present
    let output = substitute(output, '\n$', '', '')
    
    " Replace the selected text with the output
    execute line_start . ',' . line_end . 'delete'
    call append(line_start - 1, split(output, "\n"))
endfunction

function! QueryVisualSelection()
    " Get the visually selected text
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return
    endif
    " Handle partial line selections
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let selected_text = join(lines, "\n")
    
    " Determine which command to use
    let cmd = executable('llm') ? 'llm' : 'ask'
    
    " Send to LLM and get response
    let output = system('echo ' . shellescape(selected_text) . ' | ' . cmd)
    " Remove trailing newline if present
    let output = substitute(output, '\n$', '', '')
    
    " Replace the selected text with the output
    execute line_start . ',' . line_end . 'delete'
    call append(line_start - 1, split(output, "\n"))
endfunction

function! ExecutePythonSelection()
    " Get the visually selected text
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return
    endif
    " Handle partial line selections
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let selected_text = join(lines, "\n")
    
    " Execute the Python code and get output
    let output = system('python3 -c ' . shellescape(selected_text))
    " Remove trailing newline if present
    let output = substitute(output, '\n$', '', '')
    
    " Append the output after the selected text
    call append(line_end, split(output, "\n"))
endfunction

command! -nargs=? Aider call AiderCommand(<f-args>)
command! -nargs=1 LLM call AskQuestion(<q-args>)

" Visual mode mappings
vnoremap <leader>e :<C-u>call ExecuteVisualSelection()<CR>
vnoremap <leader>q :<C-u>call QueryVisualSelection()<CR>
vnoremap <leader>p :<C-u>call ExecutePythonSelection()<CR>

nnoremap <silent> - :Yazi<cr>
nnoremap <silent> _ :YaziWorkingDirectory<cr>

set autoread
au CursorHold * checktime  
