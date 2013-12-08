if exists("g:autoloaded_timl_vim")
  finish
endif
let g:autoloaded_timl_vim = 1

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_'),''))
endfunction

" Section: Number

let g:timl#vim#Number = timl#bless('timl.lang/Type', {"name": timl#symbol('timl.vim/Number')})

" Section: String

" Characters, not bytes
function! s:str_get(this, idx, ...) abort
  if type(a:idx) == type(0)
    let ch = matchstr(a:this, repeat('.', a:idx).'\zs.')
    return empty(ch) ? (a:0 ? a:1 : g:timl#nil) : ch
  endif
  return a:0 ? a:1 : g:timl#nil
endfunction

function! s:string_count(this) abort
  return exists('*strchars') ? strchars(a:this) : len(substitute(a:this, '.', '.', 'g'))
endfunction

let g:timl#vim#String = timl#bless('timl.lang/Type', {
      \ "name": timl#symbol('timl.vim/String'),
      \ "implements":
      \ {"timl.lang/ILookup":
      \    {"get": s:function("s:str_get")},
      \  "timl.lang/Counted":
      \    {"count": s:function("s:string_count")}}})

" Section: Funcref

function! s:funcall(this, args)
  return call(a:this, a:args, {'__fn__': a:this})
endfunction

let g:timl#vim#Funcref = timl#bless('timl.lang/Type', {
      \ "name": timl#symbol('timl.vim/Funcref'),
      \ "implements":
      \ {"timl.lang/IFn":
      \   {"invoke": s:function('s:funcall')}}})

" Section: List

function! s:list_get(this, idx, ...) abort
  if type(a:idx) == type(0)
    return get(a:this, a:idx, a:0 ? a:1 : g:timl#nil)
  endif
  return a:0 ? a:1 : g:timl#nil
endfunction

function! s:list_cons(this, other) abort
  return timl#persistentb(a:this + [a:other])
endfunction

let s:empty_list = timl#persistentb([])
function! s:list_empty(this) abort
  return s:empty_list
endfunction

let g:timl#vim#List = timl#bless('timl.lang/Type', {
      \ "name": timl#symbol('timl.vim/List'),
      \ "implements":
      \ {"timl.lang/Seqable":
      \    {"seq": g:timl#lang#ChunkedCons.create},
      \  "timl.lang/ILookup":
      \    {"get": s:function("s:list_get")},
      \  "timl.lang/Counted":
      \    {"count": function("len")},
      \  "timl.lang/IPersistentCollection":
      \    {"cons": s:function("s:list_cons"),
      \     "empty": s:function("s:list_empty")},
      \  "timl.lang/IFn":
      \    {"invoke": s:function("s:list_get")}}})

" Section: Dictionary

function! s:dict_seq(dict) abort
  return timl#list2(items(a:dict))
endfunction

function! s:dict_get(this, key, ...) abort
  return get(a:this, timl#str(a:key), a:0 ? a:1 : g:timl#nil)
endfunction

function! s:dict_cons(this, x) abort
  return timl#persistentb(extend(timl#transient(a:this), {timl#str(timl#first(a:x)): timl#first(timl#rest(a:x))}))
endfunction

let s:empty_dict = timl#persistentb({})
function! s:dict_empty(this) abort
  return s:empty_dict
endfunction

let g:timl#vim#Dictionary = timl#bless('timl.lang/Type', {
      \ "name": timl#symbol('timl.vim/Dictionary'),
      \ "implements":
      \ {"timl.lang/Seqable":
      \    {"seq": s:function("s:dict_seq")},
      \  "timl.lang/ILookup":
      \    {"get": s:function("s:dict_get")},
      \  "timl.lang/Counted":
      \    {"count": function("len")},
      \  "timl.lang/IPersistentCollection":
      \    {"cons": s:function("s:dict_cons"),
      \     "empty": s:function("s:dict_empty")},
      \  "timl.lang/IFn":
      \    {"invoke": s:function("s:dict_get")}}})

" Section: Float

if has('float')
  let g:timl#vim#Float = timl#bless('timl.lang/Type', {"name": timl#symbol('timl.vim/Float')})
endif

" vim:set et sw=2:
