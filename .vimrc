syntax on
set nocompatible
filetype plugin on
set number

let $PATH = $HOME . '/.local/share/mise/shims:' . $PATH

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': 'md'}]

augroup terminal_handling
    autocmd!
augroup END

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
  nnoremap <leader>a :Ag<CR>
endif

nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[
nmap <leader>E :exec 'r!'.getline('.')<CR>

set rtp+=~/.fzf
nnoremap <silent> <Leader>b :call fzf#run(fzf#wrap({'source': map(range(1, bufnr('$')), 'bufname(v:val)'), 'sink': 'buffer'}))<CR>
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
nnoremap <silent> <leader>t :Files<CR>
nnoremap <leader>h :bprevious<CR>
nnoremap <leader>l :bnext<CR>
nnoremap <leader>r :e!<CR>
nnoremap <leader><leader> :e!<CR>

function! ExecuteVisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let selected_text = join(lines, "\n")
    let expanded_text = substitute(selected_text, '%', expand('%'), 'g')
    let output = system(expanded_text)
    let output = substitute(output, '\n$', '', '')
    execute line_start . ',' . line_end . 'delete'
    call append(line_start - 1, split(output, "\n"))
endfunction

function! ExecutePythonSelection() range
    let code = join(getline(a:firstline, a:lastline), "\n")
    let output = system('python3 -c ' . shellescape(code) . ' 2>&1')
    botright new
    setlocal buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
endfunction


" ---- AI helpers --------------------------------------------------------
" :AI <question>        ask codestral via LiteLLM, answer in a split.
" :'<,'>AI <question>   same, with the selected lines sent as context.
" #AI<bang> <instr.>   (literally hash-AI-bang) write the file (:w) and pi edits it in the background.
let g:ai_model = 'openrouter/mistralai/codestral-2508'
let g:ai_pi_model = 'litellm-proxy/openrouter/mistralai/devstral-2512'

" Key comes from kv via .aliasrc. ~/.env is only a legacy fallback.
if empty($LITELLM_PROXY_API_BASE) && filereadable(expand('~/.env'))
    for s:line in readfile(expand('~/.env'))
        let s:m = matchlist(s:line, '^\s*\(export\s\+\)\?\([A-Za-z_][A-Za-z0-9_]*\)=\(.*\)$')
        if !empty(s:m) && empty(getenv(s:m[2]))
            call setenv(s:m[2], substitute(s:m[3], '^\([''"]\)\(.*\)\1$', '\2', ''))
        endif
    endfor
endif

function! AIAsk(question, has_range, line1, line2) abort
    if empty($LITELLM_PROXY_API_KEY)
        echoerr 'AI: LITELLM_PROXY_API_KEY is not set. Run load_env in a shell, then start vim from it.'
        return
    endif
    if empty($LITELLM_PROXY_API_BASE)
        let $LITELLM_PROXY_API_BASE = 'https://litellm.osmosis.page'
    endif
    let content = a:question
    if a:has_range
        let content .= "\n\n```" . &filetype . "\n" . join(getline(a:line1, a:line2), "\n") . "\n```"
    endif
    let body = tempname()
    call writefile([json_encode({'model': g:ai_model,
                \ 'messages': [{'role': 'user', 'content': content}]})], body)
    " Pass the key through stdin so it never shows up in the process list.
    let cfg = 'header = "Authorization: Bearer ' . $LITELLM_PROXY_API_KEY . '"'
    echo 'AI: asking ' . g:ai_model . '...'
    let raw = system('curl -sS --config - -H "Content-Type: application/json" -d @'
                \ . shellescape(body) . ' '
                \ . shellescape($LITELLM_PROXY_API_BASE . '/v1/chat/completions'), cfg)
    call delete(body)
    try
        let resp = json_decode(raw)
        let answer = has_key(resp, 'choices') ? resp.choices[0].message.content : string(get(resp, 'error', resp))
    catch
        let answer = raw
    endtry
    botright new
    setlocal buftype=nofile bufhidden=wipe noswapfile filetype=markdown
    call setline(1, ['> ' . a:question, ''] + split(answer, "\n"))
    redraw | echo ''
endfunction
command! -range=0 -nargs=+ AI call AIAsk(<q-args>, <count>, <line1>, <line2>)

" Split so this file itself never matches the marker.
let s:ai_marker = '#AI' . '!'
let s:ai_pattern = '#\s*AI' . '!'
let s:ai_jobs = {}
function! s:AIPiOnWrite() abort
    let file = expand('%:p')
    if has_key(s:ai_jobs, file) || match(getline(1, '$'), s:ai_pattern) < 0
        return
    endif
    let prompt = 'In the file ' . file . ' there are lines containing the marker "' . s:ai_marker
                \ . '" (possibly written as "# AI' . '!"). Each one is an instruction for you. Carry out every instruction, '
                \ . 'then remove the marker lines (or the marker text) from the file.'
    let s:ai_jobs[file] = job_start(['pi', '--print', '--no-session', '--model', g:ai_pi_model, prompt], {
                \ 'cwd': expand('%:p:h'), 'in_io': 'null',
                \ 'out_io': 'buffer', 'out_name': '[pi-log]', 'err_io': 'out', 'out_msg': 0,
                \ 'exit_cb': {j, code -> s:AIPiDone(file, code)}})
    echo 'AI: pi is working on ' . expand('%:t') . ' (log in buffer [pi-log])'
endfunction
function! s:AIPiDone(file, code) abort
    call remove(s:ai_jobs, a:file)
    checktime
    echo 'AI: pi ' . (a:code == 0 ? 'finished ' : 'failed (exit ' . a:code . ', see :b [pi-log]) ') . fnamemodify(a:file, ':t')
endfunction
augroup ai_pi
    autocmd!
    autocmd BufWritePost * call s:AIPiOnWrite()
augroup END

vnoremap <leader>e :<C-u>call ExecuteVisualSelection()<CR>
vnoremap <leader>p :call ExecutePythonSelection()<CR>
nnoremap <silent> <C-v> :vsplit \| :Yazi<cr>
const g:yazi_exec_on_open = 'tabnew'
nnoremap <silent> - :Yazi<cr>
nnoremap <silent> _ :YaziWorkingDirectory<cr>

set encoding=utf-8
set backspace=indent,eol,start
set hlsearch incsearch
set ignorecase smartcase
set autoread
au CursorHold * checktime

" Bracketed paste support
let &t_BE = "\e[?2004h"
let &t_BD = "\e[?2004l"
let &t_PS = "\e[200~"
let &t_PE = "\e[201~"
