syntax on

" Check for required executables
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
nnoremap <silent> <Leader>b :Buffers<CR>
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
nnoremap <silent> <leader>t :Files<CR>


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

command! -nargs=? Aider call AiderCommand(<f-args>)
command! -nargs=1 Ask call AskQuestion(<q-args>)


