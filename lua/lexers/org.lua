-- Org Mode LPeg lexer.

local l = require('lexer')
local token, word_match = l.token, l.word_match
local P, R, S = lpeg.P, lpeg.R, lpeg.S

local M = {_NAME = 'org'}

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

local header = token('h6', l.starts_line('******') * P(' ')) +
               token('h5', l.starts_line('*****') * P(' ')) +
               token('h4', l.starts_line('****') * P(' ')) +
               token('h3', l.starts_line('***') * P(' ')) +
               token('h2', l.starts_line('**') * P(' ')) +
               token('h1', l.starts_line('*') * P(' '))

local keyword = token('keyword', P('TODO') + P('NEXT') + P('DONE'))

local tags = token('em', l.delimited_range(':', true))

-- Block elements.
local blockquote = token(l.STRING, 
                   l.nested_pair("#+BEGIN_QUOTE", "#+END_QUOTE"))

local blockcode = token('code',
                   l.nested_pair("#+BEGIN_SRC", "#+BEGIN_SRC") +
                   l.nested_pair("#+BEGIN_EXAMPLE", "#+BEGIN_EXAMPLE"))

-- Span elements.
local link = token('link', l.nested_pair('[[', ']]') +
                           P('http://') * (l.any - l.space)^1 +
                           P('https://') * (l.any - l.space)^1)
                           
local strong = token('strong', l.delimited_range('*', true, true))
local underlined = token('underlined', l.delimited_range('_', true, true))
local em = token('em', l.delimited_range('/', true, true))
local code = token('code', l.delimited_range('~', true, true) +
                           l.delimited_range('=', true, true))

local list = token('list',
                   l.starts_line(S(' \t')^0 * (S('*+-') + R('09')^1 * '.')) *
                   S(' \t'))

M._rules = {
  {'tags', tags},
  {'keyword', keyword},
  {'header', header},
  {'blockquote', blockquote},
  {'blockcode', blockcode},
  {'list', list},
  {'whitespace', ws},
  {'link', link},
  {'strong', strong},
  {'em', em},
  {'code', code},
}

local font_size = 10
local hstyle = 'fore:red'
M._tokenstyles = {
  keyword = 'bold,back:red,fore:white',
  h6 = hstyle,
  h5 = hstyle..',size:'..(font_size + 1),
  h4 = hstyle..',size:'..(font_size + 2),
  h3 = hstyle..',size:'..(font_size + 3),
  h2 = hstyle..',size:'..(font_size + 4),
  h1 = hstyle..',size:'..(font_size + 5),
  code = l.STYLE_EMBEDDED..',eolfilled',
  link = 'underlined',
  link_url = 'underlined',
  link_label = l.STYLE_LABEL,
  strong = 'bold',
  em = 'italics',
  underlined = 'underlined',
  list = l.STYLE_CONSTANT,
}

return M
