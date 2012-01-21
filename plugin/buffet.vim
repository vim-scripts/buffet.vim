" Buffet Plugin for VIM > 7.3 version 1.0
"
" A fast, simple and easy to use pluggin for switching and managing buffers.
"
" Usage:
"
" Copy the file buffet.vim to the plugins directory.
" The command to open the buffer list is 
" 
" :Bufferlist
"
" A horizontal window is opened with a list of buffer. the buffer numbers are
" also displayed along side. The user select a buffer by
"
" 1.Entering the buffer number using keyboard. Just start typing the number using keyboard.
" The plugin will search for the buffer with that number and will keep going to the matching
" buffers. Entered number will be shown at the top you can use backspace to edit it.When you 
" are in the desired buffer, press enter or any control keys that are
" displayed at the bottom to execute any command available, on that buffer
"
" Available commands
" 
" Enter(Replace current buffer) 
" o - make window fill with selected buffer 
" h/v - (Horozontal/vertical Split) 
" g - (Go to buffer window if it is visible) 
" d - (Delete selected buffer) 
"
" 2.Move up or down using the navigation keys to reach the buffer line.
"
" 3.Doubleclick on a buffer line using the mouse. Will immediatly switch to
" that buffer
"
" To make this plugin really useful you have to assign a shortcut key for it, 
" say you want F2 key to open the buffer list. you can add the following line in your .vimrc file. 
"
" map <F2> :Bufferlist<CR>
"
" Last Change:	2011 Aug
" Maintainer:	Sandeep.c.r<sandeepcr2@gmail.com>
"
"
function! s:open_new_window(dim)
	exe a:dim . 'new buflisttempbuffer412393'  
	set nonu
	setlocal bt=nofile
	setlocal modifiable
	setlocal bt=nowrite
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal scrolloff=0
	setlocal sidescrolloff=0
	return bufnr('%')
endfunction 
function! s:open_new_vertical_window(dim)
	exe a:dim . 'vnew' 
	set nonu
	setlocal bt=nofile
	setlocal bt=nowrite
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal scrolloff=0
	setlocal sidescrolloff=0
	return bufnr('%')
endfunction 	
function! s:cursormove()
	let l:line = line('.')
	if(l:line >len(s:bufrecent)+1)
		call cursor(2,3)
	elseif(l:line ==1 )
		call cursor(len(s:bufrecent)+1,3)
	endif
endfunction
function! s:display_buffer_list()
	let l:line = 2
	if(len(s:bufrecent) == 0)
		let s:bufrecent = s:bufferlistlite
	endif

	call filter(s:bufrecent,'exists("s:bufferlistlite[v:val]") && v:val!=t:tlistbuf' )
	let l:maxlen = 0
	for l:i in s:bufrecent
		let l:temp = strlen(fnamemodify(s:bufferlistlite[l:i],':t'))
		if(l:temp > l:maxlen) 
			let l:maxlen = l:temp
		endif
	endfor
			call setline(1,"Buffet-1.0 ( Enter Number to search for a buffer number )")
	for l:i in s:bufrecent
			let l:bufname = s:bufferlistlite[l:i]
			let l:buftailname =fnamemodify(l:bufname,':t')
			let l:bufheadlname =fnamemodify(l:bufname,':h')
			let l:padlength = l:maxlen - strlen(l:buftailname) + 2
			let l:short_file_name = " ".repeat(' ',2-strlen(l:i)).l:i .'  '. l:buftailname.repeat(' ',l:padlength) . fnamemodify(l:bufname,':h') 
			if(getbufvar(str2nr(l:i),'&modified')) 
				let l:short_file_name = l:short_file_name." (+)"
			endif
			call setline(l:line,l:short_file_name)
			if(l:i==s:sourcebuffer)
				let l:fg = synIDattr(hlID('Statement'),'fg','gui')
				let l:bg = synIDattr(hlID('CursorLine'),'bg','gui')
				if(l:fg!='' )
					exe 'highlight currenttab guifg=lightgreen'
					exe 'highlight currenttab guibg='.l:bg
					exe 'match currenttab /\%'.l:line.'l.\%>1c/'
				endif
			endif
			let l:line += 1
	endfor
			call setline(l:line,"")
			let l:line+=1
			call setline(l:line,"Controls - Enter(Replace current buffer) | o(Make window fill with selected buffer) | h/v(Horizontal/Vertical Split) | g(Go to buffer window if it is visible) | d(Delete buffer) ")
			let l:fg = synIDattr(hlID('Statement'),'fg','Question')
			exe 'highlight buffethelpline guibg=black'
			exe 'highlight buffethelpline guifg=orange'
			exe '2match buffethelpline /\%1l\|\%'.l:line.'l.\%>1c/'
	call cursor(3,3)
endfunction

function! s:close()
	if(exists("t:tlistbuf"))
		unlet t:tlistbuf
		:bdelete buflisttempbuffer412393
		echo ''
	endif
endfunction

function! s:place_sign()
	setlocal cursorline
	return
	exec "sign unplace *"
	exec "sign define lineh linehl=Search texthl=Search" 
	exec "sign place 10 name=lineh line=".line('.')." buffer=" . t:tlistbuf
endfunction

function! s:getallbuffers()
	let l:buffers = filter(range(1,bufnr('$')), 'buflisted(v:val)')
	let l:return = {}
	for i in l:buffers
		let l:bufname = bufname(i)
			if(strlen(l:bufname)==0) 	
				continue	
			endif
		let l:return[i] = l:bufname
	endfor
	return l:return
endfunction

function! s:printmessage(msg)
	setlocal modifiable
	call setline(len(s:bufrecent)+2,a:msg)
	setlocal nomodifiable
endfunction

function! s:press(num)
	if(a:num==-1)
		let s:keybuf = strpart(s:keybuf,0,len(s:keybuf)-1)
	else
		let s:keybuf = s:keybuf . a:num
	endif
	setlocal modifiable
	call setline(1 ,'Buffet-1.0 - Searching for buffer:'.s:keybuf.' (Use backspace to edit)')
	let l:index = index(s:bufrecent,s:keybuf)
	"echo l:index
	"echo s:bufrecent
	if(l:index != -1)
		let l:index += 2
		exe "normal "+l:index+ "gg"
	endif
	setlocal nomodifiable
endfunction
function! s:toggle()

	let s:keybuf = ''
	if(exists("t:tlistbuf"))
		call s:close()
		return 0
	endif

	let s:bufferlistlite = s:getallbuffers()
	if(len(s:bufrecent) == 0 )
		for x in keys(s:bufferlistlite)
			call add(s:bufrecent,x)
		endfor
	endif
	let s:sourcebuffer = bufnr('%')
	let t:tlistbuf = s:open_new_window(len(s:bufrecent)+4)
	let s:buflistwindow = winnr()
	setlocal cursorline
	call s:display_buffer_list()
	"call matchadd('String','[\/\\][^\/\\]*$')  
	call cursor(3,3)
	setlocal nomodifiable
	map <buffer> <silent> <2-leftrelease> :call <sid>gototab(0)<cr>
	map <buffer> <silent> <C-R> :call <sid>gototab(0)<cr>
	map <buffer> <silent> <C-M> :call <sid>gototab(0)<cr>
	map <buffer> <silent> d :call <sid>deletebuffer(0)<cr>
	map <buffer> <silent> D :call <sid>deletebuffer(1)<cr>
	map <buffer> <silent> o :call <sid>gototab(1)<cr>
	map <buffer> <silent> O :call <sid>gototab(1)<cr>
	map <buffer> <silent> g :call <sid>gotowindow()<cr>
	map <buffer> <silent> G :call <sid>gotowindow()<cr>
	map <buffer> <silent> s :call <sid>split('h')<cr>
	map <buffer> <silent> S :call <sid>split('h')<cr>
	map <buffer> <silent> h :call <sid>split('h')<cr>
	map <buffer> <silent> H :call <sid>split('h')<cr>
	map <buffer> <silent> v :call <sid>split('v')<cr>
	map <buffer> <silent> V :call <sid>split('v')<cr>
	map <buffer> <silent> r :call <sid>refresh()<cr>
	map <buffer> <silent> 0 :call <sid>press(0)<cr>
	map <buffer> <silent> 1 :call <sid>press(1)<cr>
	map <buffer> <silent> 2 :call <sid>press(2)<cr>
	map <buffer> <silent> 3 :call <sid>press(3)<cr>
	map <buffer> <silent> 4 :call <sid>press(4)<cr>
	map <buffer> <silent> 5 :call <sid>press(5)<cr>
	map <buffer> <silent> 6 :call <sid>press(6)<cr>
	map <buffer> <silent> 7 :call <sid>press(7)<cr>
	map <buffer> <silent> 8 :call <sid>press(8)<cr>
	map <buffer> <silent> 9 :call <sid>press(9)<cr>
	map <buffer> <silent> <BS> :call <sid>press(-1)<cr>
	map <buffer> <silent> <Esc> :call <sid>close()<cr>
	augroup  Tlistaco1
			autocmd!
			au  BufLeave <buffer> call <sid>close()
			au  CursorMoved <buffer> call <sid>cursormove()
	augroup END
endfunction
function! s:deletebuffer(force)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]") )
		let l:selectedbuffer = str2nr(s:bufrecent[l:llindex])
		if(bufwinnr(l:selectedbuffer)==-1)
			if(getbufvar(str2nr(l:selectedbuffer),'&modified') && a:force == 0 ) 
				call s:printmessage("Buffer contents modified. Use 'D' to force delete.")
			else
				exe "bdelete! ".l:selectedbuffer
				call s:toggle()
				call s:toggle()
			endif
		else
			call s:printmessage("Cannot delete buffer when it is displayed in a window")
		endif
	else
		call s:close()
	endif
endfunction


function! s:gotowindow()
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		call s:close()
		call s:goto_buffer(s:bufrecent[l:llindex])
	else
		call s:close()
	endif
endfunction

function! s:gototab(isonly)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		call s:close()
		call s:switch_buffer(s:bufrecent[l:llindex])
		if(a:isonly == 1 && winnr('$')>1)
			exe 'only'
		endif
	else
		call s:close()
	endif
endfunction

function! s:split(mode)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		call s:close()
		call s:split_buffer(s:bufrecent[l:llindex],a:mode)
	else
		call s:close()
	endif
endfunction

function! s:goto_buffer(bufferno)
	let l:windowofbuffer = bufwinnr(a:bufferno)
	if(l:windowofbuffer != -1)
		exe l:windowofbuffer. ' wincmd w'
	endif
endfunction


function! s:split_buffer(bufferno,mode)
	if(a:mode == 'v')
		exe 'belowright vert '.a:bufferno. ' sbuf'
	elseif(a:mode == 'h')
		exe 'belowright ' .a:bufferno. ' sbuf'
	endif
	if(exists("s:buflinenos[a:bufferno]"))
		exe "normal "+s:buflinenos[a:bufferno] + "gg"
	endif
endfunction

function! s:switch_buffer(bufferno)
	exe a:bufferno. ' buf!'
	if(exists("s:buflinenos[a:bufferno]"))
		exe "normal "+s:buflinenos[a:bufferno] + "gg"
	endif
endfunction

function! s:updaterecent()
		let l:bufname = bufname("%")
		let l:j = bufnr('%')
		if(strlen(l:bufname) > 0 && getbufvar(l:j,'&modifiable')  ) 
			call filter(s:bufrecent, 'v:val !='. l:j)
			call insert(s:bufrecent,l:j.'')
		endif
endfunction

function! s:savelineno()
	let s:buflinenos[bufnr('%')] = line('.')
endfunction

let s:bufrecent = []
let s:buflinenos = {}
let s:bufferlistlite =  {}
let s:bufliststatus  = 0
let s:keybuf  = ''
augroup Tlistacom
		autocmd!
		au  BufEnter * call <sid>updaterecent()
		au  BufLeave * call <sid>savelineno()
augroup END

command! Bufferlist :call <sid>toggle()
