(import-macros {: req-f : ref-f : epi : ep : when-let} :util.macros)
; (import-macros {: nmaps : map : cmd : plug : space : ui-ignore-filetype : la : br : let-g : au!} :kaza.macros)
(import-macros { : map : cmd : plug : space : ui-ignore-filetype : la : br : let-g : au!} :kaza.macros)

(macro lcnf [file_name]
  `(vim.cmd (table.concat ["source ~/.config/nvim/after_opt/" ,file_name ] "")))

(local myutil (require :lua.util))
(local nmaps myutil.nmaps)
(macro lazy-load [name ?opts]
  (if (= ?opts nil)
    `{1 ,name :event ["User plug-lazy-load"] :lazy true}
    (let [core {1 name :event ["User plug-lazy-load"] :lazy true}]
      (each [k v (pairs ?opts)]
        (tset core k v))
      `core)))


[
{1 :rktjmp/hotpot.nvim}

;;; snippet

{1 :SirVer/ultisnips
:event ["User plug-lazy-load"]
 }
{1 :honza/vim-snippets
 :event ["User plug-lazy-load"]}
{1 :L3MON4D3/LuaSnip
 :event ["User plug-lazy-load"]
 :version "v1.1.0"
 :config (lambda []
           (local ls (require :luasnip))
           (local types (require :luasnip.util.types))
           (ls.config.set_config
            ;ls.config.set_config
            {:history true
             :updateevents "TextChanged, TextChangedI"
             :delete_check_events "TextChanged"
             :enable_autosnippets true
             :ext_opts
             {types.choiceNode
              {:active
               {:virt_text [{"● " "Error" }]}}}})
           (lcnf :luasnip.lua)
           (lcnf :luasnip_key.lua)
           (vim.cmd "imap <silent><expr> <C-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-k>'")
           (vim.cmd "smap <silent><expr> <C-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-k>'")
           (vim.cmd "imap <silent><expr> <C-q> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-q>'")
           (vim.cmd "smap <silent><expr> <C-q> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-q>'")
           (vim.keymap.set :n :<leader>k "<cmd>source ~/.config/nvim/after_opt/luasnip.lua<cr>"))}

;;; lint
{1 :mfussenegger/nvim-lint
 :event ["User plug-lazy-load"]
 :dependencies [:bufbuild/vim-buf]
 :config (λ []
             (tset (require :lint) :linters_by_ft {:proto [:buf_lint]
                                                   :javascript [:eslint_d]
                                                   :typescript [:eslint_d]
                                                   :vue [:eslint_d]
                                                   :go [:golangcilint]
                                                  })
             (let [g (vim.api.nvim_create_augroup :my_lint_ {:clear true})]
              (au!
                g
                [:BufWritePost]
                (ref-f :try_lint :lint))))}

;;; UI

{1 :nvim-tree/nvim-web-devicons
 :event ["User plug-lazy-load"]
 :config (λ [] ((req-f :set_icon :nvim-web-devicons) {:fnl {:icon "󰌪" :color "#428850" :name :fnl}}))}

{1 :lambdalisue/fern.vim
 :lazy true
 :event ["User plug-lazy-load"]
 :dependencies [:lambdalisue/fern-git-status.vim
            {1 :lambdalisue/fern-renderer-nerdfont.vim
             :dependencies [:lambdalisue/nerdfont.vim]}
            :yuki-yano/fern-preview.vim]
 :config (λ []
           (tset vim.g :fern#renderer :nerdfont)
           ; (tset vim.g :fern_renderer_devicons_disable_warning true)
           (lcnf "fern.vim")
           (nmaps
             :<Space>n
             :fern
             [[:p (cmd "Fern . -drawer -toggle -reveal=%") "open fern on a current working directory"]
              [:d (cmd "Fern %:h -drawer -toggle -reveal=%") "open fern on a parent directory of a current buffer"]])
           )}

{1 :stevearc/oil.nvim
    :config (la
            (tset _G
             :get_oil_winbar
             (la
              (let [dir (ref-f :get_current_dir :oil)]
               (if dir
                (vim.fn.fnamemodify dir ":~")
                (vim.api.nvim_buf_get_name 0)))))
            (ref-f :setup :oil
             {:win_options
               {:signcolumn :yes:2
               :winbar "%!v:lua.get_oil_winbar()"
               }
             :view_options {:show_hidden true}})
            (map :n :<F3> (cmd :Oil) "open oil")
            (nmaps
             :<Space>oi
             :oil
             [["l" (cmd :Oil) "open oil"]]))}
{1 :refractalize/oil-git-status.nvim
  :dependencies :stevearc/oil.nvim
 :config true}
; {1 :kyazdani42/nvim-tree.lua ; INFO: startup time
;  :dependencies :nvim-tree/nvim-web-devicons
;  :disabe true
;  :config (λ []
;            ((req-f :setup :nvim-tree) {:actions {:open_file {:quit_on_open true}}})
;            (nmaps
;              :<space>n
;              :nvim-tree
;              [[:t (cmd :NvimTreeToggle) :toggle]
;               [:r (cmd :NvimTreeRefresh) :refresh]
;               [:f (cmd :NvimTreeFindFile) :find]]))}
; {1 :nvim-neo-tree/neo-tree.nvim
;  :branch :v2.x
;  :dependencies [:nvim-lua/plenary.nvim
;             :nvim-tree/nvim-web-devicons
;             :MunifTanjim/nui.nvim]}
; {1 :glepnir/dashboard-nvim
;  :disable true
;  :config (λ [] (tset vim.g :dashboard_default_executive :telescope))}

; {1 :rinx/nvim-minimap ; WARN: startup time
;  :config (λ []
;            (vim.cmd "let g:minimap#window#width = 10")
;            (vim.cmd "let g:minimap#window#height = 35"))}
{1 :gorbit99/codewindow.nvim
 :event ["User plug-lazy-load"]
:config (λ []
        (local codewindow (require :codewindow))
        (codewindow.setup
          {:use_treesitter true
           :use_lsp true})
        (codewindow.apply_default_keybinds))}

;; scrollbar
; {1 :petertriho/nvim-scrollbar
;  :event ["User plug-lazy-load"]
;  :config (λ [] ((req-f :setup :scrollbar) {:excluded_buftypes [:terminal]
;                                            :excluded_filetypes (ui-ignore-filetype)}))}


;  :config (la (ref-f :setup :incline))}
; {1 :feline-nvim/feline.nvim
;  :init (la (ref-f :setup :feline)
;              ((-> (require :feline) (. :winbar) (. :setup))))}
{1 :nvim-lualine/lualine.nvim
 :event ["User plug-lazy-load"]
 :config (la (ref-f :setup :lualine {:options {:globalstatus true}}))
 :dependencies {1 :nvim-tree/nvim-web-devicons
            :lazy true }}

; notify
{1 :rcarriga/nvim-notify
 :event :VeryLazy
 :config (lambda []
           ((. (require :notify) :setup)
            {:stages :fade_in_slide_out
             :background_colour :FloatShadow
             :timeout 3000
             })
           ; (set vim.notify (require :notify))
           )
 }

;{1 :folke/snacks.nvim
; :priority 1000
; :lazy false
; :opts {
;   :bigfile {:enabled true}
;   :notifier {:enabled true}
;   :quickfile {:enabled true}
;   :statuscolumn {:enabled true}
;   :words {:enabled true}}}
; {1 :folke/noice.nvim
;  ; :event ["User plug-lazy-load"]
;  :config (lambda []
;            ((. (require :noice) :setup)
;             {:cmdline {:enabled true}
;              :messages {:enabled true}
;              :popupmenu {:enabled true}
;              ; :errors {:view :popup}
;              :notify {:enabled true}})
;            ; (ref-f :setup :noice
;            ;        {:lsp {:progress {:enabled false}}})
;            )
;  :dependencies [:MunifTanjim/nui.nvim :rcarriga/nvim-notify]}

; {1 :anuvyklack/windows.nvim
;  :event ["User plug-lazy-load"]
;  :dependencies [
;             "anuvyklack/middleclass"
;             "anuvyklack/animation.nvim"
;             ]
;  :config (lambda []
;            (tset vim.o :winwidth 10)
;            (tset vim.o :winminwidth 10)
;            (tset vim.o :equalalways false)
;            (ref-f :setup :windows)
;            (vim.keymap.set :n :<C-w>z (cmd :WindowsMaximize))
;            (vim.keymap.set :n :<C-w>_ (cmd :WindowsMaximizeVertically))
;            (vim.keymap.set :n :<C-w>| (cmd :WindowsMaximizeHorizontally))
;            (vim.keymap.set :n :<C-w>= (cmd :WindowsEqualize)))}

; resize window
{1 :simeji/winresizer}

{1 :lukas-reineke/indent-blankline.nvim
 :event ["User plug-lazy-load"]
 :main "ibl"
 :config (la ((req-f :setup :ibl)
              {;:show_current_context true
               ;:show_current_context_start true
               ;:space_char_blankline " "
               ;:indent {:highlight [:RainbowRed :RainbowYellow]
               }))
 }

 {1 "DNLHC/glance.nvim"
  :config (la (ref-f :setup :glance)
              (nmaps
                :<Space>g
                :glance
                [[:D (cmd "Glance definitions") "definitions"]
                 [:R (cmd "Glance references") "references"]
                 [:Y (cmd "Glance type_definitions") "type definitions"]
                 [:M (cmd "Glance implementations") "implementations"]]))}

; {1 :edluffy/specs.nvim
;  ; :event ["User plug-lazy-load"]
;  :config (la ((req-f :setup :specs) {:show_jumps true
;                                      :min_jump 10
;                                      :popup {:delay_ms 0
;                                              :inc_ms 10
;                                              :blend 10
;                                              :width 50
;                                              :winhl :Pmenu
;                                              :fader (let [specs (require :specs)]
;                                                       (. specs :linear_fader))
;                                              :resizer (let [specs (require :specs)]
;                                                         (. specs :shrink_resizer))}
;                                      :ignore_filetypes []
;                                      :ignore_buftypes {:nofile true}}))
;  }

;; telescope {{{
{1 :nvim-telescope/telescope.nvim
 :event ["User plug-lazy-load"]
 :dependencies [{1 :nvim-lua/plenary.nvim}]
 :config (λ []
          (local telescope (. (require :telescope) :setup))
          (telescope
            {:defaults {
             :file_ignore_patterns [".git" "node_modules" "vendor" "target" ".cache" ".vscode" ".idea" ".sass-cache" ".hg" ".svn"]}}
            {:pickers
             {:colorscheme {:enable_preview true}}})
          (local prefix ((. (require :kaza.map) :prefix-o) :n :<Space>t :telescope))
          (prefix.map :f (la ((-> (require :telescope.builtin) (. :find_files))
                            {:hidden true})) "find files")
          (prefix.map :g (la ((-> (require :telescope.builtin) (. :live_grep))
                            {:additional_args [:--hidden]})) "find files")
          (prefix.map :b "<cmd>Telescope buffers<cr>" "buffers")
          (prefix.map :h "<cmd>Telescope help_tags<cr>" "help tags")
          (prefix.map :t "<cmd>Telescope<cr>" "telescope")
          (prefix.map :o "<cmd>Telescope oldfiles<cr>" "old files")
          (prefix.map :c "<cmd>Telescope colorscheme<cr>" "colorscheme")
          (prefix.map :r "<cmd>Telescope file_browser<cr>" "file_browser")
          (prefix.map :cb "<cmd>Telescope current_buffer_fuzzy_find<cr>" "current_buffer_fuzzy_find"))}

{1 :nvim-telescope/telescope-file-browser.nvim
 :dependencies :telescope.nvim
 :config (la ((req-f :load_extension :telescope) :file_browser))
 :dependencies [:nvim-telescope/telescope.nvim]}

; {1 :nvim-telescope/telescope-packer.nvim
;  :dependencies :telescope.nvim
;  :config (la ((req-f :load_extension :telescope) :packer))
;  :dependencies [:nvim-telescope/telescope.nvim]}


; {1 :nvim-telescope/telescope-frecency.nvim
;  :dependencies :telescope.nvim
;  :config (la ((req-f :load_extension :telescope) :frecency))
;  :dependencies [:tami5/sqlite.lua :nvim-telescope/telescope.nvim]}
; :kkharji/sqlite.lua
;; }}}

{1 :Cassin01/wf.nvim
 :event ["User plug-lazy-load"]
 :branch :Fixes#105
 ; :version :update
 :config (la (ref-f :setup :wf {:theme :chad})
             (require :user))}

{1 :crusj/bookmarks.nvim
  :keys [{1 "<tab><tab>" :mode [:n]}]
  :branch :main
  :dependencies [:nvim-web-devicons]
  :config (la
    (ref-f :setup :bookmarks)
    (ref-f :load_extension :telescope :bookmarks))}

{1 :xiyaowong/nvim-transparent
 :cmd :TransparentEnable
 :config (λ []
           ((-> (require :transparent) (. :setup))
            {:enable false}))}
{1 :akinsho/bufferline.nvim
 :version :*
 :dependencies :nvim-tree/nvim-web-devicons
 ; :config (λ []
 ;           (ref-f :setup :bufferline {:options {:separator_style :slant}}))
 ; :init (λ [] (ref-f :setup :bufferline {}))
 :event ["User plug-lazy-load"]
 :config (la
           (ref-f :setup :bufferline
                  {:options {:show_close_icon false
                             :show_buffer_close_icons false
                             :color_icons false
                             :indicator {:style :none}
                             :separator_style [" " " "]
                             }})
           (nmaps
              :<Space>b
              :bufferline
              [[:p (cmd :BufferLinePick) :pick]
               [:c (cmd :BufferlinePickClose) :close]
               [(br :r) (cmd :BufferLineCycleNext) "next"]
               [(br :l) (cmd :BufferLineCyclePrev) "prev"]
               [:e (cmd :BufferLineSortByExtension) "sort by extension"]
               [:d (cmd :BufferLineSortByDirectory) "sort by directory"]])

            (fn get-hl [name part]
              (let [target (vim.api.nvim_get_hl_by_name name 0)]
                (if
                  (= part :fg)
                  (.. :# (vim.fn.printf :%0x (. target :foreground)))
                  (= part :bg)
                  (.. :# (vim.fn.printf :%0x (. target :background)))
                  nil)))

            (local {: lazy} (require :kaza.cmd))
            (local set-hl
              (lambda [patt]
                (local bg (get-hl :Normal :bg))
                (when (not= bg nil)
                  (fn bufferline [bg]
                    (local {: unfold-iter} (require :util.list))
                    (local res (vim.api.nvim_exec "highlight" true))
                    (local lines (unfold-iter (res:gmatch "([^\r\n]+)")))
                    (each [_ line (ipairs lines)]
                      (local elements (unfold-iter (line:gmatch "%S+")))
                      (local hi-name (. elements 1))
                      (when (not= hi-name nil)
                        (when (not= (hi-name:match patt) nil)
                          (vim.cmd (.. "hi " hi-name " guibg=" bg))))
                      nil))
                   (bufferline bg))))
            (lazy 1000 set-hl "^BufferLine.*$")
            (let [g (vim.api.nvim_create_augroup :bufferline-overwrite-devicon {:clear true})]
              (au!
                g
                [:WinEnter]
                (lazy 1000 set-hl "^BufferLineDevIcon.*$"))))}

{1 :sheerun/vim-polyglot}
{1 :David-Kunz/markid}
{1 :nvim-treesitter/nvim-treesitter
 :build ":TSUpdate"
 ; :event ["User plug-lazy-load"]
 ; :dependencies {1 :p00f/nvim-ts-rainbow :dependencies :nvim-treesitter}
 :config (λ []
           ; ((. (require :orgmode) :setup_ts_grammar))
           ((. (require "nvim-treesitter.configs") :setup)
            {
             ; :incremental_selection {:enable true
             ;                         :keymaps {:init_selection "<CR>"
             ;                                  :node_incremental "<CR>"
             ;                                  :node_decremental "<BS>"
             ;                                  :scope_incremental "<S-CR>"}
             ;                         }
             :ensure_installed [ "nix" "org" "bash"]  ; "lua" "rust" "c" "org"
             :sync_install false
             :auto_install true
             :ignore_install [ "javascript" "markdown" "git"]
             :highlight {:enable true
                         :disable (la
                                    (each [_ t (ipairs [ "c" "rust" "org" "vim" "tex" "typescript" "markdown" "git"])]
                                      (when (= t vim.bo.filetype)
                                        (lua "return false")))
                                     true)
                         :additional_vim_regex_highlighting ["org"]}
             ; :rainbow {:enable true
             ;           :extended_mode true
             ;           :max_file_lines nil}
             :markid { :enable true }
            :disable (λ [lang buf]
                (local max_filesize (* 100 1024))
                (local (ok status) (pcall vim.loop.fs_stat (vim.api.nvim_buf_get_name buf)))
                (if (and ok status (> status.size max_filesize))
                  true
                  nil))
             :additional_vim_regex_highlighting false}))}
:nvim-treesitter/nvim-treesitter-context
:nvim-treesitter/playground

{1 :yuki-yano/fzf-preview.vim
 :branch :release/remote}

{1 :SmiteshP/nvim-navic
 :config (lambda []
           (ref-f :setup :nvim-navic {:highlight false
                                      :separator " ➤ "}))
 :dependencies :neovim/nvim-lspconfig }

; {1 :norcalli/nvim-colorizer.lua
;  :config (λ []
;            ((. (require :colorizer) :setup)))}

; {1 :haringsrob/nvim_context_vt}

;; fold
; {1 :kevinhwang91/nvim-ufo
;  :dependencies :kevinhwang91/promise-async
;  :init (la (vim.cmd "UfoDetach"))
;  ; :init (la
;  ;          ; (local capabilities (vim.lsp.protocol.make_client_capabilities))
;  ;          ; (set capabilities.textDocument.foldingRange {:dynamicRegistration true
;  ;          ;                                              :lineFoldingOnly false})
;  ;          ; (local language_servers {})
;  ;          ; (each [_ ls (ipairs language_servers)]
;  ;          ;   ((-> (require :lspconfig) (. :ls) (. :setup)) {:capabilities capabilities}))
;  ;          (ref-f :setup :ufo))
;  }

; {1 :mattn/ctrlp-matchfuzzy
;  :init (λ []
;           (tset g :ctrlp_match_func {:match :ctrlp_matchfuzzy#matcher}))}
{1 :ctrlpvim/ctrlp.vim
 :lazy true
 :cmd :CtrlP
 :init (λ []
          (local g vim.g)
          (tset g :ctrlp_map :<Nop>)
          (tset g :ctrlp_working_path_mode :ra)
          (tset g :ctrlp_open_new_file :r)
          (tset g :ctrlp_extensions [:tag :quickfix :dir :line :mixed])
          (tset g :ctrlp_match_window "bottom,order:btt,min:1,max:18")
          (nmaps
            :<Space>p
            :ctrlp
            [[:a ::<c-u>CtrlP<Space> :default]
             [:b :<cmd>CtrlPBuffer<cr> :buffer]
             [:d :<cmd>CtrlPDir<cr> "directory"]
             [:f :<cmd>CtrlP<cr> "all files"]
             [:l :<cmd>CtrlPLine<cr> "grep in a current file"]
             [:m :<cmd>CtrlPMRUFiles<cr> "file history"]
             [:q :<cmd>CtrlPQuickfix<cr> "quickfix"]
             [:s :<cmd>CtrlPMixed<cr> "file and buffer"]
             [:t :<cmd>CtrlPTag<cr> "tag"]]))}

; Show git status on left of a code.
{1 :lewis6991/gitsigns.nvim ; WARN startup
 :event ["User plug-lazy-load"]
 :dependencies {1 :nvim-lua/plenary.nvim}
 :config (λ []
           ((. (require :gitsigns) :setup)
            {:current_line_blame true}))}

; {1 :sindrets/diffview.nvim :dependencies :nvim-lua/plenary.nvim }

{1 :kana/vim-submode
 :event ["User plug-lazy-load"]
 :config (λ []
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<Space>s> :<C-w>>)
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<Space>s< :<C-w><)
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<Space>s+ :<C-w>+)
           ((. vim.fn :submode#enter_with) :bufmove :n "" :<Space>s- :<C-w>-)
           ((. vim.fn :submode#map) :bufmove :n "" :> :<C-w>>)
           ((. vim.fn :submode#map) :bufmove :n "" :< :<C-w><)
           ((. vim.fn :submode#map) :bufmove :n "" :+ :<C-w>+)
           ((. vim.fn :submode#map) :bufmove :n "" :- :<C-w>-))}


{1 :ziontee113/icon-picker.nvim
 :event ["User plug-lazy-load"]
 :dependencies {1 :stevearc/dressing.nvim :event ["User plug-lazy-load"]}
 :config (λ []
           (ref-f :setup :icon-picker {:disable_legacy_commands true}))}

;;; lsp

; {1 :williamboman/nvim-lsp-installer
;  :config (λ []
;            ((. (require :nvim-lsp-installer) :on_server_ready)
;             (λ [server] (server:setup {}))))}
{1 :williamboman/mason.nvim
 ; :event ["User plug-lazy-load"]
 ; :dependencies [{1 "nvimtools/none-ls.nvim"}
 :dependencies [{1 "jose-elias-alvarez/null-ls.nvim"}
            {1 "jayp0521/mason-null-ls.nvim"}]
 :config (λ []
           (ref-f :setup :mason)
           ; (ref-f :setup :null-ls)
           (local null_ls (require :null-ls))
           (local b (. null_ls :builtins))
           (local mason_null_ls (require :mason-null-ls))
           ((. mason_null_ls :setup)
                  {:ensure_installed [:stylua]
                   :automatic_installation true
                   :handlers {1 (λ [source_name] nil)
                              :stylua (λ [source_name]
                                        ((. null_ls :register) (-> b (. :formatting) (. :stylua)))) }})
           ;; ref: https://alpha2phi.medium.com/neovim-for-beginners-lsp-using-null-ls-nvim-bd954bf86b40
           ;; ref: https://www.reddit.com/r/neovim/comments/un3s55/how_to_pass_arguments_for_formatting_in_nullls/
           (local sources
             [((-> b (. :formatting) (. :stylua) (. :with)) {:extra_args [:--indent-type :Spaces]})])
           ((. null_ls :setup) {:sources sources}))

 }
; {1 :williamboman/mason-lspconfig.nvim}

{1 :onsails/lspkind-nvim
 :config (λ [] ((. (require :lspkind) :init) {}))}

; {1 "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
;  :config (λ [] ((. (require :lsp_lines) :setup)))}

;; enhance quick fix
{1 :kevinhwang91/nvim-bqf
 :ft :qf}

{1 :weilbith/nvim-code-action-menu
 :cmd :CodeActionMenu
 :init (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<Space>f :code-action-menu)]
            (prefix.map "" "<cmd>CodeActionMenu<cr>" :action)))}

;; error list
{1 :folke/trouble.nvim
 :event ["User plug-lazy-load"]
 :dependencies :nvim-tree/nvim-web-devicons
 :config (λ [] ((-> (require :trouble) (. :setup)) {}))}

;; cmp plugins
{1 :hrsh7th/nvim-cmp
 :event ["User plug-lazy-load"]
 :dependencies [{1 :hrsh7th/cmp-buffer :dependencies :nvim-cmp}
            {1 :hrsh7th/cmp-path :dependencies :nvim-cmp}
            {1 :hrsh7th/cmp-nvim-lsp :dependencies :nvim-cmp}
            {1 :hrsh7th/cmp-nvim-lua :dependencies :nvim-cmp}
            {1 :hrsh7th/cmp-cmdline :dependencies :nvim-cmp}
            {1 :hrsh7th/cmp-calc :dependencies :nvim-cmp}
            {1 :hrsh7th/cmp-nvim-lsp-document-symbol :dependencies :nvim-cmp}
            ; {1 :kdheepak/cmp-latex-symbols}
            {1 :saadparwaiz1/cmp_luasnip :dependencies [:nvim-cmp :LuaSnip]}
            ; :nvim-orgmode/orgmode
            {1 :uga-rosa/cmp-dictionary
             :dependencies :nvim-cmp
             :config (λ []
                       (local path (vim.fn.expand "~/.config/nvim/data/aspell/en.dict"))
                       (ref-f :setup :cmp_dictionary
                        {:paths [:/usr/share/dict/words]
                         :first_case_insensitive true
                         :document {
                         :enable true
                         :command [ "wn" "${label}" "-over" ]}}))}
            {1 :Cassin01/cmp-gitcommit
             :dependencies :nvim-cmp
             :config (λ []
                       (ref-f :setup :cmp-gitcommit
                              {:insertText (λ [val emoji] (.. val ":" emoji " "))
                               :typesDict {:build {:label :build
                                                   :emoji "🏗️"
                                                   :documentation "Changes that affect the build system or external dependencies"
                                                   :scopes [:gulp :broccoli :npm]}
                                           :chore {:label "chore"
                                                   :emoji "🤖"
                                                   :documentation "Other changes that dont modify src or test files"}
                                           :ci {:label "ci"
                                                :emoji "👷"
                                                :documentation "Changes to our CI configuration files and scripts"
                                                :scopes ["Travisi" "Circle" "BrowserStack" "SauceLabs" :Gitflow]}
                                           :docs {:label "docs"
                                                  :emoji "📚"
                                                  :documentation "Documentation only changes"}
                                           :feat {:label :feat
                                                  :emoji"✨"
                                                  :documentation "A new feature"}
                                           :fix {:label "fix"
                                                 :emoji "🐛"
                                                 :documentation "A bug fix"}
                                           :perf {:label "perf"
                                                  :emoji "⚡️"
                                                  :documentation "A code change that improves performance"}
                                           :refactor {:label "refactor"
                                                      :emoji "🧹"
                                                      :documentation "A code change that neither fixes a bug nor adds a feature"}
                                           :revert {:label "revert"
                                                    :emoji "⏪"
                                                    :documentation "Reverts a previous commit"}
                                           :style {:label "style"
                                                   :emoji "🎨"
                                                   :documentation "Changes that do not affect the meaning of the code"}
                                           :test {:label "test"
                                                  :emoji "🚨"
                                                  :documentation "Adding missing tests or correcting existing tests"}}}))
            }
            {1 :quangnguyen30192/cmp-nvim-ultisnips
             :dependencies :nvim-cmp
             :config (λ [] (ref-f :setup :cmp_nvim_ultisnips {}))}
            {1 :zbirenbaum/copilot-cmp :dependencies :nvim-cmp}
            ; :neovim/nvim-lspconfig
            ]
 :config (λ []
           (local cmp (require :cmp))
           (local lspkind (require :lspkind))
           (cmp.setup
             {:snippet {:expand (λ [args]
                                  ; (print args)
                                  (vim.notify (vim.inspect args))
                                  ; ((. vim.fn :UltiSnips#Anon) args.body)
                                  (ref-f :lsp_expand :luasnip args.body)
                                  )}
              :sources (cmp.config.sources
                         [
                          {:name :gitcommit :group_index 2}
                          {:name :copilot :group_index 2}
                          {:name :luasnip :group_index 5}
                          {:name :nvim_lsp :group_index 2}
                          {:name :ultisnips :group_index 2}
                          ; {:name :orgmode}
                          {:name :lsp_document_symbol}
                          ; {:name :latex_symbols
                          ; :option {:strategy 0}}
                          ; {:name :skkeleton :group_index 5}
                          {:name :buffer
                           :option {:get_bufnrs (λ []
                                                  (vim.api.nvim_list_bufs))}}
                          {:name :dictionary
                           :group_index 5
                           :keyword_length 2}])
              :formatting {:format (fn [entry vim_item]
                                     ; (print (vim.inspect entry.source.name))
                                     (if (= entry.source.name :copilot)
                                       (do
                                         (tset vim_item :kind " Copilot")
                                         (tset vim_item :kind_hl_group :CmpItemKindCopilot)
                                          vim_item)
                                        (= entry.source.name :luasnip)
                                       (do
                                         (tset vim_item :kind "󰆏 Luasnip")
                                         (tset vim_item :kind_hl_group :DevIconGraphQL)
                                         vim_item)
                                       (= entry.source.name :skkeleton)
                                          (do
                                            ; (tset vim_item :kind " SKK")
                                            (tset vim_item :kind " SKK")
                                            (tset vim_item :kind_hl_group :CmpItemKindCopilot)
                                            vim_item)
                                       (= entry.source.name :gitcommit)
                                          (do
                                            ; (tset vim_item :kind " SKK")
                                            (tset vim_item :kind " Git")
                                            (tset vim_item :kind_hl_group :CmpItemKindCopilot)
                                            vim_item)
                                        (= entry.source.name :dictionary)
                                        (do
                                          (tset vim_item :kind "󰘝 Dict")
                                          (tset vim_item :kind_hl_group :DevIconFsscript)
                                          vim_item)
                                       ((lspkind.cmp_format {:with_text true :maxwidth 50}) entry vim_item)))}
              :mapping (cmp.mapping.preset.insert
                         {
                          ; :<C-i> (cmp.mapping
                          ;          (λ [fallback]
                          ;            (req-f :expand_or_jump_forwards  :cmp_nvim_ultisnips.mappings fallback))
                          ;          [:i :s])
                          :<C-S-i> (cmp.mapping
                                   (λ [fallback]
                                     (req-f :expand_or_jump_forwards  :cmp_nvim_ultisnips.mappings fallback))
                                   [:i  :s])
                          ; :<tab> (cmp.mapping (λ [fallback]
                          ;                       (if
                          ;                         (cmp.visible)
                          ;                         (cmp.select_next_item)
                          ;                         (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
                          ;                           (and (not= col 0)
                          ;                                (= (-> (vim.api.nvim_buf_get_lines 0 (- line 1) line true)
                          ;                                       (. 1)
                          ;                                       (: :sub col col)
                          ;                                       (: :match :%s))
                          ;                                   nil)))
                          ;                         (cmp.mapping.complete)
                          ;                         (fallback))))
                          :<c-e> (cmp.mapping.abort)
                          :<UP> vim.NIL
                          :<Down> vim.NIL
                          ; :<c-p> (cmp.mapping.select_prev_item)
                          ; :<c-n> (cmp.mapping.select_next_item)
                          :<cr> (cmp.mapping.confirm {:select false}) }) })
           (vim.api.nvim_set_hl 0 :CmpItemKindCopilot {:fg :#6CC644})
           (cmp.setup.cmdline :/ {:mapping (cmp.mapping.preset.cmdline)
                                  :sources [{:name :buffer}]})
           (cmp.setup.cmdline :: {:mapping (cmp.mapping.preset.cmdline)
                                  :sources (cmp.config.sources [{:name :path}] [{:name :cmdline}])}))}
:jubnzv/virtual-types.nvim

;; highlighting other uses of the current word under the cursor
; {1 :RRethy/vim-illuminate}


{1 :neovim/nvim-lspconfig
 :event ["User plug-lazy-load"]
 :dependencies [:hrsh7th/cmp-nvim-lsp
            {1 :williamboman/mason.nvim
             :event ["User plug-lazy-load"]}
            {1 :williamboman/mason-lspconfig.nvim
             :event ["User plug-lazy-load"]}
            {1 :lukas-reineke/lsp-format.nvim
             :event ["User plug-lazy-load"]}]
 ;:dependencies :cmp-nvim-lsp
 :config (lambda []
           (lcnf :lsp_conf.lua))
 ; :config
 ; (lambda []
 ;   (require :core.pack.lsp))
 }

{1 :tami5/lspsaga.nvim
 :event ["User plug-lazy-load"]
 :dependencies [:nvim-web-devicons]
 :config (λ [] ((. (require :lspsaga) :setup) {}))}

;; show type of argument
; {1 :ray-x/lsp_signature.nvim
;  :event ["User plug-lazy-load"]
;  :config (λ [] ((. (require :lsp_signature) :setup) {}))}

;; tagbar alternative
; :simrat39/symbols-outline.nvim
; {1 :stevearc/aerial.nvim
;  :config (λ []
;            ((req-f :setup :aerial) {:on_attach (λ [bufnr]
;                                                  (let [prefix ((. (require :kaza.map) :prefix-o ) :n :<space>a :aerial)]
;                                                    (prefix.map-buf bufnr :n "t" (cmd :AerialToggle!) :JumpForward)
;                                                    (prefix.map-buf bufnr :n "{" (cmd :AerialPrev) :JumpForward)
;                                                                               (prefix.map-buf bufnr :n "}" (cmd :AerialNext) :JumpBackward)
;                                                    (prefix.map-buf bufnr :n "[[" (cmd :AerialPrevUp) :JumpUpTheTree)
;                                                                                (prefix.map-buf bufnr :n "]]" (cmd :AerialNextUp) :JumpUpTheTree)))}))}
{1 :sidebar-nvim/sidebar.nvim
:event ["User plug-lazy-load"]
 :dependencies [{1 :jremmen/vim-ripgrep :event ["User plug-lazy-load"]}]
 :config (la
           (local section {:title :Environment
                           :icon :
                           :setup (lambda [ctx]
                                    nil)
                           :update (lambda [ctx]
                                     nil)
                           :draw (lambda [ctx]
                                   "> string here\n> multiline")
                           :heights {:groups {:MyHighlightGroup {:gui :#C792EA
                                                                 :fg :#ff0000
                                                                 :bg :#00ff00}}
                                     :links {:MyHighlightLink :Keyword}}})
           (ref-f
               :setup
               :sidebar-nvim
               {:initial_width 21
                :sections [:datetime section :git :todos :buffers :files :symbols :diagnostics ]
                :todos {:icon :
                        :ignored_paths ["~"]
                        :initially_closed true}}))
 :init (la
           (nmaps
             :<Space>i
             :sidebar
             [[:t (cmd :SidebarNvimToggle) :toggle]
              [:f (cmd :SidebarNvimFocus) :focus]]))
 ;:rocks [:luatz]
 }

; {1 :hrsh7th/vim-vsnip
;  :disable true
;  :dependencies [:hrsh7th/vim-vsnip-integ
;             :rafamadriz/friendly-snippets]}

;;; runner
; {1 :michaelb/sniprun
;  :build "bash install.sh"}
; {1 :thinca/vim-quickrun
;  :setup (λ []
;           (map :n :<space>or (cmd :QuickRun) "[others] quickrun")) }


;;; copilot
{1 :zbirenbaum/copilot.lua
 :event ["User plug-lazy-load"]
 ; :dependencies [{1 :github/copilot.vim :event ["User plug-lazy-load"]
 ;             :config (λ [] (tset vim.g :copilot_no_tab_map true))
 ;             }]
 :config (lambda [] (vim.defer_fn
               (lambda [] ((. (require :copilot) :setup)
                           {:filetypes {:yaml true}}))
               100))}

; {1 :github/copilot.vim
;  :event ["User plug-lazy-load"]
;  :config (λ [] (tset vim.g :copilot_no_tab_map true))} ;; dependencies command `:Copilot restart`

{1 :zbirenbaum/copilot-cmp
 ; :dependencies [{1 :zbirenbaum/copilot.lua :event ["User plug-lazy-load"]}]
 ; :event ["User plug-lazy-load"]
 :config (la (ref-f :setup :copilot_cmp))
 }
{1 "yetone/avante.nvim"
  :event ["User plug-lazy-load"]
  :version false
  :build "make"
  :dependencies ["nvim-treesitter/nvim-treesitter"
                 "stevearc/dressing.nvim"
                 "nvim-lua/plenary.nvim"
                 "MunifTanjim/nui.nvim"
                 ; The below dependencies are optional,
                 "nvim-tree/nvim-web-devicons"; or echasnovski/mini.icons
                 "zbirenbaum/copilot.lua";  for providers='copilot'
                 {1  "HakonHarnes/img-clip.nvim"
                  :event ["User plug-lazy-load"]
                  :opts {:default {:embed_images_as_base64 false
                                   :prompt_for_file_name false
                                   :drag_and_drop {:insert_mode true}
                                   :use_absolute_path true}}}
                 {1 :MeanderingProgrammer/render-markdown.nvim
                  :opts {
                        :file_types {:markdown :Avante}
                        :ft {:markdown :Avante}}}]
    :config (λ []
        (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/avante.lua"))}

;;; vim
{1 :Shougo/echodoc.vim
 :event ["User plug-lazy-load"]
 :init (λ []
          (tset vim.g :echodoc#enable_at_startup true)
          (tset vim.g :echodoc#type :floating))}

;; thank you tpope
{1 :tpope/vim-fugitive
 :event ["User plug-lazy-load"]
 :cmd [:Git :Gdiff]
 :config (λ []
          (let [ prefix ((. (require :kaza.map) :prefix-o) :n "<Space>g" :git)]
            (prefix.map "g" "<cmd>Git<cr>" "add")
            (prefix.map "c" "<cmd>Git commit<cr>" "commit")
            (prefix.map "w" "<cmd>Git commit -m \"wip\"<cr>" "wip commit")
            (prefix.map "p" (lambda []
                              (local branch (vim.fn.trim (vim.fn.system "git branch --show-current")))
                              (when (and (not= branch "main") (not= branch "master"))
                                (vim.fn.execute (.. "Git push origin " branch))
                                ((require :notify) "pushing to remote branch " branch))) "push")
            (prefix.map "f" (lambda []
                              (local branch (vim.fn.trim (vim.fn.system "git branch --show-current")))
                              (when (and (not= branch "main") (not= branch "master"))
                                (vim.fn.execute (.. "Git push -f origin " branch)) "")
                                ((require :notify) "pushed to remote branch " branch)
                                ) "push")
            (prefix.map "l" "<cmd>Git log<cr>" "log")
            (prefix.map "t" "<cmd>Git log --graph --pretty=oneline --abbrev-commit --date=relative<cr>" "log")
            (prefix.map "a" (lambda []
                              (local path (vim.fn.expand :%:p))
                              (vim.cmd (.. "Git add " path))
                              ) "add current")
            ))}

; {1 :neogitOrg/neogit
;  :dependencies {1 :nvim-lua/plenary.nvim
;                 2 :sindrets/diffview.nvim
;                 3 :nvim-tele.lua/telescope.nvim
;                 :event ["User plug-lazy-load"]}
;  :config (lambda []
;            ((-> (require :neogit) (. :setup)) {})
;            (let [ prefix ((. (require :kaza.map) :prefix-o) :n "<Space>gn" :neogit)]
;              (prefix.map "l" "<cmd>Nogit log<cr>" "log")))
;  }
; {1 :isakbm/gitgraph.nvim
;  :dependencies [:sindrets/diffview.nvim]
;  :config (lambda []
;             (let [prefix ((. (require :kaza.map) :prefix-o) :n "<Space>gn" :neogit)]
;               (prefix.map "l" (lambda []
;                                   ((-> (require :gitgraph) (. :draw)) {} {:all true :max_count 5000})
;                                 ) "log")))
;  :opts {:symbols {:merge_commit :●
;                   :commit :○}}}
{1 :rbong/vim-flog
 :event ["User plug-lazy-load"]
 :dependencies {1 "tpope/vim-fugitive" :event ["User plug-lazy-load"]}
 :config (λ []
          (let [ prefix ((. (require :kaza.map) :prefix-o) :n "<Space>g" :git)]
            (prefix.map "nl" "<cmd>vert Flogsplit<cr>" "log")))
 }
{1 :tpope/vim-rhubarb :event ["User plug-lazy-load"]} ; enable :Gbrowse
{1 :tpope/vim-commentary :event ["User plug-lazy-load"]}
{1 :LudoPinelli/comment-box.nvim
   :event ["User plug-lazy-load"]
   :config (lambda []
             (local cb (require :comment-box))
             (fn fnum [f num]
                (lambda []
                  (f num)))
             (nmaps :<Space>o :comment-box
                    [[:c (fnum cb.ccbox 1) "ccbox"]
                     [:b (fnum cb.cabox 7) "cabox"]
                     [:l (fnum cb.llline 9) "llline"]]))}
{1 :tpope/vim-unimpaired :event ["User plug-lazy-load"]}
{1 :tpope/vim-surround :event ["User plug-lazy-load"]}
{1 :tpope/vim-abolish :event ["User plug-lazy-load"]}
; {1 :tpope/vim-rsi ; insert mode extension
   ;  :config (la (tset vim.g :rsi_non_meta true))}
{1 :vim-utils/vim-husk :event ["User plug-lazy-load"]}
{1 :tpope/vim-repeat :event ["User plug-lazy-load"]}
{1 :tpope/vim-sexp-mappings-for-regular-people :dependencies :vim-sexp}
{1 :guns/vim-sexp
 :ft [:fennel]
 :lazy true
 :config (λ []
          (tset vim.g :sexp_filetypes "clojure,scheme,lisp,timl,fennel")
          (tset vim.g :sexp_enable_insert_mode_mappings false))}


;;; util
{1 :kana/vim-textobj-user
 :event ["User plug-lazy-load"]
 :config (λ [] (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/textobj.vim"))}

{1 :michaeljsmith/vim-indent-object
 :event ["User plug-lazy-load"]}
; {1 :Cassin01/hyper-witch.nvim
;  :init (λ []
;           (tset vim.g :hwitch#prefixes _G.__kaza.prefix))}

:tyru/capture.vim
:tani/vim-typo

{1 :majutsushi/tagbar
 :event ["User plug-lazy-load"]
 :config (λ []
          (tset vim.g :tagbar_type_fennel {:ctagstype :fennel
                                           :sort 0
                                           :kinds ["f:functions" "v:variables" "m:macros" "c:comments"]})
          ((. ((. (require :kaza.map) :prefix-o) :n :<Space>a :tagbar) :map)
           :t :<cmd>TagbarToggle<cr> :toggle))}
{1 :tyru/open-browser.vim
 :event ["User plug-lazy-load"]
 :config (λ []
           (local prefix ((. (require :kaza.map) :prefix-o) :n :<leader>s :open-browser))
           (prefix.map "" "<Plug>(openbrowser-smart-search)" "search")
           (map :v "<leader>s" "<Plug>(openbrowser-smart-search)" "search"))}
{1 :mbbill/undotree
 :event ["User plug-lazy-load"]
 :init (λ []
          ((. ((. (require :kaza.map) :prefix-o) :n :<Space>u :undo-tree) :map)
           :t :<cmd>UndotreeToggle<cr> :toggle))}
{1 :junegunn/vim-easy-align
 :event ["User plug-lazy-load"]
 :init (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<Space>ea :easy-align)]
            (prefix.map "" "<Plug>(EasyAlign)" :align))
          (map :x "<Space>ea" "<Plug>(EasyAlign)" :align)) }
{1 :terryma/vim-multiple-cursors
 :event ["User plug-lazy-load"]}

; :rhysd/clever-f.vim
{1 :Jorengarenar/vim-MvVis
 :event ["User plug-lazy-load"]} ; Move visually selected text. Ctrl-HLJK
{1 :terryma/vim-expand-region
 :event ["User plug-lazy-load"]
 :config (λ []
          (vim.cmd "vmap v <Plug>(expand_region_expand)")
          (vim.cmd "vmap <C-v> <Plug>(expand_region_shrink)"))}

{1 :ggandor/leap.nvim
 :event ["User plug-lazy-load"]
 ; :config (λ [] (ref-f :set_default_keymaps :leap))
 }
{1 :yuki-yano/fuzzy-motion.vim
 :event ["User plug-lazy-load"]
 :config (lambda []
           (tset vim.g :fuzzy_motion_matchers ["fzf" "kensaku"])

           (nmaps
             :<Space>k
             :kensaku
             [["k" (la
                     (local opts {:prompt "kensaku> "})
                     (vim.ui.input opts (lambda [input]
                                          (vim.cmd (.. "Kensaku "  input " | set hlsearch"))))) "kensaku"]
              ["f" (la (vim.cmd :FuzzyMotion)) "fuzzy-motion"]])
           )
 }

;; move dir to dir
{1 :francoiscabrol/ranger.vim
 :event ["User plug-lazy-load"]
 :dependencies {1 :rbgrouleff/bclose.vim :event ["User plug-lazy-load"]}
 :config (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<Space>r :ranger)]
            (prefix.map :r :<cmd>Ranger<cr> "start at here")
            (prefix.map :t :<cmd>RangerNewTab<cr> "new tab")))}

;;; move
{1 :Shougo/vimproc.vim
 :event ["User plug-lazy-load"]
 :build "make"}

{1 :jinh0/eyeliner.nvim
 :config (lambda []
           (ref-f :setup :eyeliner {:highlight_on_key true}))}

;; Jump to any visible line in the buffer by using letters instead of numbers.
{1 :skamsie/vim-lineletters
 :event ["User plug-lazy-load"]
 :config (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<Space>l :lineletters)]
            (prefix.map "" "<Plug>LineLetters" "jump to line"))) }

{1 :Cassin01/emacs-key-source.nvim
 :event ["User plug-lazy-load"]}

; {1 "cbochs/portal.nvim"
;     :dependencies [
;         "cbochs/grapple.nvim"  ; Optional: provides the "grapple" query item
;         "ThePrimeagen/harpoon" ; Optional: provides the "harpoon" query item
;     ]
;     :config (lambda [] (ref-f :setup :portal))
;  }

{1 :andymass/vim-matchup
 :event ["User plug-lazy-load"]
 :config (la (tset (. vim :g) :matchup_matchparen_offscreen {:method :popup}))}

;; mark
{1 :kshenoy/vim-signature
 :event ["User plug-lazy-load"]
 :config (la
           (local {: goto-line
                   : universal-argument
                   : inc-search
                   : kill-line2end
                   : kill-line2begging} (require :emacs-key-source))
          (map :i :<C-g> goto-line :goto-line)
          (map :i :<C-s> inc-search :inc-search)
          (map :i :<C-S-U> "<C-O>v$hc" :kill-line2end)
          ; (map :i :<C-S-u> kill-line2end :kill-line2end)
          (map :n :<C-s> inc-search :inc-search))}

:mhinz/neovim-remote

;; Plugin to help me stop repeating the basic movement key.
{1 :takac/vim-hardtime
 :event ["User plug-lazy-load"]
 :config (la (let-g hardtime_showmsg false)
             (let-g hardtime_default_on true))}

; {1 :notomo/cmdbuf.nvim
;  :config (λ []
;            ;;; FIXME I don't know how to declare User autocmd.
;            (nmaps :q :cmdbuf [[:: (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight)) "cmdbuf"]
;                               [:l (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :lua/cmd})) "lua"]
;                               [:/ (λ [] ((req-f :split_open :cmdbuf) vim.o.cmdwinheight {:type :vim/search/forward})) :search-forward]
;                               ["?" (λ [] ((. (require :cmdbuf) :split_open) vim.o.cmdwinheight {:type :vim/search/backward})) :search-backward]]))}

;; translation
{1 :skanehira/translate.vim
 :event ["User plug-lazy-load"]
 :config (λ []
          (tset vim.g :translate_source :en)
          (tset vim.g :translate_target :ja)
          (tset vim.g :translate_popup_window false)
          (tset vim.g :translate_winsize 10)
          (vim.keymap.set :n :<space>kj
           (lambda []
            (tset vim.g :translate_source :en)
            (tset vim.g :translate_target :ja))
           {:desc "[translate] en2jp"})
          (vim.keymap.set :n :<space>ke
           (lambda []
            (tset vim.g :translate_source :ja)
            (tset vim.g :translate_target :en))
           {:desc "[translate] jp2en"})
          (vim.cmd "nnoremap gr <Plug>(Translate)")
          (vim.cmd "vnoremap <c-t> :Translate<cr>"))}

;; zen
; :junegunn/limelight.vim
; :junegunn/goyo.vim
; :amix/vim-zenroom2
{1 :folke/zen-mode.nvim
    :config (la
            (ref-f :setup :zen-mode
             {:window {:width 180}})
            (map :n :<Space>z (cmd :ZenMode) "[zenn-mode] toggle"))}

;; web browser
{1 :thinca/vim-ref
 :event ["User plug-lazy-load"]
 :config (la (vim.cmd "source ~/.config/nvim/fnl/core/pack/conf/vim-ref.vim"))}

;; log
;; {1 :wakatime/vim-wakatime
;;  :event ["User plug-lazy-load"]}

{1 :ThePrimeagen/vim-apm
 :event ["User plug-lazy-load"]}

:echasnovski/mini.nvim

;;; language

;; sche
{1 :Cassin01/sche.nvim
 :dependencies [:rcarriga/nvim-notify]
 :config (lambda []
           (local sche (require :sche))
           (sche.setup {;:sche_path (vim.fn.expand "~/all_year/sche.nvim/my_calendar.sche")
                        :notify_todays_schedule false
                        :notify_tomorrows_schedule false
                        :sche_path (vim.fn.expand "~/.config/nvim/data/24.sche")
                        :syntax {:month "'^\\(\\d\\|\\d\\d\\)月'"}}))}

; ;; deno
; {1 :vim-denops/denops.vim
;  :event ["User plug-lazy-load"]}
; {1 :lambdalisue/kensaku.vim}
; ; {1 :Cassin01/adoc_preview.nvim}
; ; {1 :Cassin01/fetch-info.nvim
; ;  :require :ms-jpq/lua-async-await
; ;  :setup (λ []
; ;           (local a (require :plug.async))
; ;           (local {: u-cmd} (require :kaza))
; ;           (u-cmd :MyGetInfo (la
; ;                               ((. (require :kaza.client) :start) "echo nvim_exec(\'GInfoM\', v:true)"))))}
; {1 :ellisonleao/weather.nvim
;  :event ["User plug-lazy-load"]
;  :config (λ [] (tset vim.g :weather_city :Tokyo))}

; ; {1 :vim-skk/skkeleton :dependencies  [ :vim-denops/denops.vim ]
; ;  :event [:InsertEnter]
; ; :config (λ []
; ;           (let [g (vim.api.nvim_create_augroup :init-skkeleton {:clear true})]
; ;             (au! g :User
; ;                  (vim.fn.skkeleton#config
; ;                    {;:eggLikeNewline false
; ;                     :globalJisyoEncoding :euc-jp
; ;                     :immediatelyJisyoRW true
; ;                     :registerConvertResult false
; ;                     :keepState true
; ;                     :selectCandidateKeys :asdfjkl
; ;                     :setUndoPoint true
; ;                     :showCandidatesCount 4
; ;                     :usePopup true
; ;                     :globalJisyo "~/.config/nvim/data/skk/SKK-JISYO.L"
; ;                     :userJisyo "~/.skkeleton"})
; ;                  {:pattern :skkeleton-initialize-pre})
; ;             (au! g :User (let [cmp (require :cmp)]
; ;                            (cmp.setup.buffer {:view {:entries :native}}))
; ;                  {:pattern :skkeleton-enable-pre})
; ;             (au! g :User (let [cmp (require :cmp)]
; ;                            (cmp.setup.buffer {:view {:entries :custom}}))
; ;                  {:pattern :skkeleton-disable-pre})
; ;             (au! g :User :redrawstatus {:pattern :skkeleton-mode-changed}))
; ;           (map :i :<c-j> (plug "(skkeleton-toggle)") "[skkeleton] toggle")
; ;           (map :c :<c-j> (plug "(skkeleton-toggle)") "[skkeleton] toggle"))}
; ; {1 :Cassin01/cmp-skkeleton :dependencies  [ "nvim-cmp" "skkeleton" ] }
; ; {1 :delphinus/skkeleton_indicator.nvim
; ;  :event ["User plug-lazy-load"]
; ;  :config (λ [] (ref-f :setup :skkeleton_indicator {}))}

; {1 :uki00a/denops-pomodoro.vim}
; {1 :skanehira/denops-docker.vim}
{1 :epwalsh/pomo.nvim
 :cmd ["TimerStart" "TimerRepeat"]
 :lazy true
 :init (λ [] (ref-f :setup :pomo {}))
 :dependencies [:rcarriga/nvim-notify]}

; ;; Async
; {1 :ms-jpq/lua-async-await
;  :branch :neo}

;; text
{1 :sedm0784/vim-you-autocorrect
 :event ["User plug-lazy-load"]
 :init (λ []
          (let [prefix ((. (require :kaza.map) :prefix-o) :n :<Space>a :auto-collect)]
            (prefix.map "e" "<cmd>EnableAutocorrect<cr>" "enable auto correct")))}

;; html
:mattn/emmet-vim

; ;; tailwind
; {1 :mrshmllow/document-color.nvim
;  :config (λ []
;            ((. (require :document-color) :setup) {:mode :backkground})) }
{1 :brenoprata10/nvim-highlight-colors
 :event ["User plug-lazy-load"]
 :config (la
           (ref-f :setup :nvim-highlight-colors)
           (nmaps
             :<Space>h
             :highlight-colors
             [["]" (la (ref-f :turnOn :nvim-highlight-colors)) "turn on highlight colors"]
              ["[" (la (ref-f :turnOff :nvim-highlight-colors)) "turn off highlight colors"]
              ["t" (la (ref-f :toggle :nvim-highlight-colors)) "toggle highlight colors"]
              ]))}

;; org
; {1 :nvim-orgmode/orgmode ; INFO startup
;  :config (λ []
;            ((. (require :orgmode) :setup) {:org_agenda_files ["~/org/*"]}))}

;; nu
{1 :LhKipp/nvim-nu
 :config (la (ref-f :setup :nu {}))}

;; lua
{ 1 :bfredl/nvim-luadev
 :event ["User plug-lazy-load"]}
{1 :mhartington/formatter.nvim
 :event [:BufWritePre]}

;; binary
{1 :Shougo/vinarise
 :event ["User plug-lazy-load"]}

;; fennel
{1 :bakpakin/fennel.vim
 :event ["User plug-lazy-load"]}  ; syntax
; {1 :jaawerth/fennel-nvim
;  :event ["User plug-lazy-load"]} ; native fennel support
; :Olical/conjure       ; interactive environment
; {1 :Olical/nvim-local-fennel
;  :event ["User plug-lazy-load"]}

;; rust
{1 :rust-lang/rust.vim
 :event ["User plug-lazy-load"]}

;; go
{1 :ray-x/go.nvim
 :dependencies ["ray-x/guihua.lua"
               "neovim/nvim-lspconfig"
               ;"nvim-treesitter/nvim-treesitter"
               ]
 :config (la (ref-f :setup :go {})
             (let [g (vim.api.nvim_create_augroup :GoFormat {:clear true})]
               (au!
                 g
                 [:BufWritePre]
                 (ref-f :goimports :go.format)
                 {:pattern :*.go})))
 :event ["CmdlineEnter"]
 :ft [:go :gomod]
 :build ":lua require(\"go.install\").update_all_sync()"
 }

;; sql
{1 :nanotee/sqls.nvim}

; ;; tex
; {1 :https://github.com/lervag/vimtex
;  :config (λ []
;            (tset vim.g :vimtex_view_general_viewer "/Applications/Skim.app/Contents/SharedSupport/displayline")
;            (tset vim.g :vimtex_view_general_options "@line @pdf @tex")
;            )}

; {1 :Cassin01/texrun.vim
;  ; :event ["User plug-lazy-load"]
;  :setup (λ [] (tset vim.g :texrun#file_name [:l02.tex :sample.tex :resume.tex]))}

;; vim
{1 :LeafCage/vimhelpgenerator
 :event ["User plug-lazy-load"]
 :init (λ []
          (tset vim.g :vimhelpgenerator_defaultlanguage "en")
          (tset vim.g :vimhelpgenerator_version :0.0.1)
          (tset vim.g :vimhelpgenerator_contents {:contents true
                                                  :introduction true
                                                  :usage true
                                                  :interface true
                                                  :variables true
                                                  :commands true
                                                  :key-mappings true
                                                  :functions true
                                                  :setting true
                                                  :todo true
                                                  :changelog false}))} ; doc generator

;; markdown
{1 :godlygeek/tabular :lazy true :cmd [:Tabularize]}
;{1 :preservim/vim-markdown
; :config (λ []
;           (tset vim.g :vim_markdown_conceal_code_blocks false))}
{1 :iamcco/markdown-preview.nvim
 :build "cd app && yarn install"
 :init (λ []
          (tset vim.g :mkdp_filetypes [:markdown])
          (tset vim.g :mkdp_auto_close false)
          (tset vim.g :mkdp_preview_options {:katex {}
                                             :disable_sync_scroll false})
          (local prefix ((. (require :kaza.map) :prefix-o) :n :<Space>om :markdown-preview))
          (prefix.map :p :<Plug>MarkdownPreview "preview"))
 :cmd [:MarkdownPreviewToggle :MarkdownPreview :MarkdownPreviewStop]
 :ft [:markdown]}

{1 :ellisonleao/glow.nvim
 :cmd [:Glow :GlowInstall]
 :build ":GlowInstall"
 :init (λ []
          (local prefix ((. (require :kaza.map) :prefix-o) :n "<Space>g" :glow))
          (prefix.map :mp "<cmd>Glow<cr>" "preview"))}

;; asciidoc
{1 :habamax/vim-asciidoctor
 :config (la (tset vim.g :asciidoctor_fenced_languages [:python :c :javascript :haskell]))
}

; {1
;     :marioortizmanero/adoc-pdf-live.nvim
;     :config (la ((. (require :adoc_pdf_live) :setup)))
; }

;; japanese
{1 :deton/jasegment.vim
 :event ["User plug-lazy-load"]}
{1 :catppuccin/nvim
 :name :catppuccin
 ; :config (λ []
 ;           ; (ref-f :setup :catppuccin {:flavour :macchiato})
 ;           (vim.api.nvim_command "colorscheme catppuccin-macchiato"))
 }

;;; color
; {1 :ujihisa/unite-colorscheme
;  :event ["User plug-lazy-load"]
;  :dependencies [:Shougo/unite.vim]}

(lazy-load :folke/tokyonight.nvim)
(lazy-load :shaunsingh/nord.nvim)
(lazy-load :rebelot/kanagawa.nvim)
(lazy-load :sam4llis/nvim-tundra)
(lazy-load :Mofiqul/dracula.nvim)
(lazy-load :zanglg/nova.nvim)
(lazy-load :projekt0n/github-nvim-theme)
; {1 :maxmx03/FluoroMachine.nvim :event ["User plug-lazy-load"] :lazy true}
:maxmx03/FluoroMachine.nvim

;; Not currenlty using
(lazy-load :altercation/vim-colors-solarized   ) ; solarized
(lazy-load :croaker/mustang-vim                ) ; mustang
(lazy-load :jeffreyiacono/vim-colors-wombat    ) ; wombat
(lazy-load :nanotech/jellybeans.vim            ) ; jellybeans
(lazy-load :vim-scripts/Lucius                 ) ; lucius
(lazy-load :vim-scripts/Zenburn                ) ; zenburn
(lazy-load :mrkn/mrkn256.vim                   ) ; mrkn256
(lazy-load :jpo/vim-railscasts-theme           ) ; railscasts
(lazy-load :therubymug/vim-pyte                ) ; pyte
(lazy-load :tomasr/molokai                     ) ; molokai
(lazy-load :chriskempson/vim-tomorrow-theme    ) ; tomorrow night
(lazy-load :vim-scripts/twilight               ) ; twilight
(lazy-load :w0ng/vim-hybrid                    ) ; hybrid
(lazy-load :freeo/vim-kalisi                   ) ; kalisi
(lazy-load :morhetz/gruvbox                    ) ; gruvbox
(lazy-load :toupeira/vim-desertink             ) ; desertink
(lazy-load :sjl/badwolf                        ) ; badwolf
(lazy-load :itchyny/landscape.vim              ) ; landscape
(lazy-load :joshdick/onedark.vim               ) ; onedark in atom
(lazy-load :gosukiwi/vim-atom-dark             ) ; atom-dark
(lazy-load :liuchengxu/space-vim-dark          ) ; space-vim-dark
(lazy-load :kristijanhusak/vim-hybrid-material ) ; hybrid_material
(lazy-load :drewtempelmeyer/palenight.vim      ) ; palenight
(lazy-load :haishanh/night-owl.vim             ) ; night owl
(lazy-load :arcticicestudio/nord-vim           ) ; nord
(lazy-load :cocopon/iceberg.vim                ) ; iceberg
(lazy-load :hzchirs/vim-material               ) ; vim-material
(lazy-load :relastle/bluewery.vim              ) ; bluewery
(lazy-load :mhartington/oceanic-next           ) ; OceanicNext
;(lazy-load :Mangeshrex/uwu.vim                 ) ; uwu
; (lazy-load :ulwlu/elly.vim                     ) ; elly
; (lazy-load :michaeldyrynda/carbon.vim          ) ; carbon
(lazy-load :rafamadriz/neon                    ) ; neon
]
