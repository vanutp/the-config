{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  nixpkgs.overlays = [
    (self: super: {
      neovim = pkgs-unstable.neovim;
    })
  ];

  home.packages = with pkgs; [
    neovide
  ];

  programs.nixvim = {helpers, ...}: let
    fixTree = helpers.mkRaw ''
      function()
        local api = require('nvim-tree.api')
        local view = require('nvim-tree.view')
        if not view.is_visible() then
          api.tree.open()
        end
      end
    '';
    enableInlayHints = ''
      if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    '';
  in {
    enable = true;
    colorschemes.tokyonight.enable = true;
    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
      smartindent = true;
      ignorecase = true;
      smartcase = true;
      guifont = "${config.preferences.font.monospace}:h12";
    };
    extraConfigLua = ''
      vim.diagnostic.config {
        update_in_insert = true,
      }

      require('nvim-web-devicons').setup {
        default = true;
        strict = true;
      }

      require('launch').setup()
      require('dapui').setup()
    '';
    extraConfigLuaPre = ''
      local wakatimeToday
      vim.loop.new_timer():start(0, 60 * 1000, vim.schedule_wrap(function()
        vim.fn.WakaTimeToday(function(data)
          wakatimeToday = data:gsub('\n', "")
        end)
      end))
    '';
    extraPlugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      vim-wakatime
      nvim-scrollview
      nvim-dap-ui
      (pkgs.vimUtils.buildVimPlugin {
        name = "launch-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "dasupradyumna";
          repo = "launch.nvim";
          rev = "16ab170bbd82c37d5a0295235bfad57df3255246";
          hash = "sha256-cze08vAfOyxRLzOjUgGPSD1qPKHCwz807XfP2nBq0HU=";
        };
      })
    ];
    extraPackages = with pkgs; [
      vscode-extensions.vadimcn.vscode-lldb.adapter
    ];
    keymaps = [
      {
        key = "<C-S-c>";
        action = ''<ESC>l"+Pl'';
        mode = "v";
        options = {noremap = true;};
      }
      {
        key = "<C-S-p>";
        action = ''"+P'';
        mode = ["n" "v"];
        options = {noremap = true;};
      }
      {
        key = "<C-S-v>";
        action = "<C-R>+";
        mode = ["i" "c"];
        options = {noremap = true;};
      }
      {
        key = "<C-S-v>";
        action = ''<C-\\><C-n>"+Pi'';
        mode = "t";
        options = {noremap = true;};
      }

      {
        key = "<M-CR>";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      }
      {
        key = "<C-Tab>";
        action = "<cmd>BufferNext<CR>";
      }
      {
        key = "<C-S-Tab>";
        action = "<cmd>BufferPrevious<CR>";
      }
      {
        key = "<C-S-w>";
        action = "<cmd>BufferClose<CR>";
        mode = ["i" "n"];
      }
      {
        key = "<C-r>";
        action = "<cmd>Telescope projects<CR>";
      }
      {
        key = "<C-BS>";
        action = "<C-w>";
        mode = "i";
        options = {noremap = true;};
      }
      {
        key = "<C-Del>";
        action = "<cmd>norm! dw<CR>";
        mode = "i";
      }
      {
        key = "<C-M-l>";
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
      }
      {
        key = "<F2>";
        action = ":IncRename ";
      }
      {
        key = "<F12>";
        action = "<cmd>lua require('dapui').toggle()<CR>";
      }
      {
        key = "<F7>";
        action = "<cmd>DapStepInto<CR>";
      }
      {
        key = "<F8>";
        action = "<cmd>DapStepOver<CR>";
      }
      {
        key = "<S-F8>";
        action = "<cmd>DapStepOut<CR>";
      }
      {
        key = "<F9>";
        action = "<cmd>DapContinue<CR>";
      }
      {
        key = "<F1>";
        action = "<cmd>NvimTreeToggle<CR>";
      }
      {
        key = "<C-z>";
        action = "<cmd>norm! u<CR>";
        mode = ["i" "n"];
        options = {noremap = true;};
      }
      {
        key = "<C-S-z>";
        action = "<cmd>norm! <C-r><CR>";
        mode = ["i" "n"];
        options = {noremap = true;};
      }
    ];
    autoCmd = [
      {
        event = "VimEnter";
        # https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup
        callback = helpers.mkRaw ''
          function(e)
            -- buffer is a directory
            local directory = vim.fn.isdirectory(e.file) == 1

            if not directory then
              return
            end

            -- create a new, empty buffer
            vim.cmd.enew()

            -- wipe the directory buffer
            vim.cmd.bw(e.buf)

            -- change to the directory
            vim.cmd.cd(e.file)

            -- open the tree
            require("nvim-tree.api").tree.open()
          end
        '';
      }
      {
        event = "DirChanged";
        pattern = "global";
        callback = helpers.mkRaw ''
          function(e)
            require("nvim-tree.api").tree.change_root(e.cwd)
            require("nvim-tree.api").tree.open()
          end
        '';
      }
      {
        event = "BufEnter";
        pattern = "NvimTree*";
        callback = fixTree;
      }
    ];
    plugins = {
      luasnip.enable = true;
      nvim-autopairs.enable = true;
      treesitter.enable = true;
      auto-save = {
        enable = true;
        extraOptions.execution_message.enabled = false;
      };
      inc-rename.enable = true;
      typescript-tools.enable = true;
      # TODO: crashes on alt+enter for some reason
      #noice = {
      #  enable = true;
      #  presets.inc_rename = true;
      #  lsp = {
      #    progress.enabled = false;
      #  };
      #};
      auto-session = {
        enable = true;
        extraOptions.post_restore_cmds = [fixTree];
      };
      direnv.enable = true;
      rustaceanvim = {
        enable = true;
        settings.server = {
          on_attach = "function(client, bufnr) ${enableInlayHints} end";
          settings = ''
            function(project_root)
              return {
                diagnostics = {
                  disabled = { 'collapsible_else_if' }
                }
              }
            end
          '';
        };
      };
      dap.enable = true;
      telescope.enable = true;
      project-nvim = {
        enable = true;
        package = pkgs.vimUtils.buildVimPlugin {
          name = "my-plugin";
          src = pkgs.fetchFromGitHub {
            owner = "vanutp";
            repo = "project.nvim";
            rev = "5ec81f7a8c8b0ce08a1603b297f11bf61177000f";
            hash = "sha256-yh0Et/pXzlucmCon8TG/IodgcL4ycFjpNYywnDjJayk=";
          };
        };
        enableTelescope = true;
      };
      lualine = {
        enable = true;
        sections.lualine_y = [
          {
            name = helpers.mkRaw ''
              function()
                return wakatimeToday
              end
            '';
          }
        ];
      };
      barbar = {
        enable = true;
      };
      nvim-tree = {
        enable = true;
        updateFocusedFile.enable = true;
        syncRootWithCwd = true;
        actions.changeDir.global = true;
      };
      cmp = {
        enable = true;
        autoEnableSources = true;

        cmdline = {
          "/" = {
            mapping = helpers.mkRaw "cmp.mapping.preset.cmdline()";
            sources = [{name = "buffer";}];
          };
          ":" = {
            mapping = helpers.mkRaw "cmp.mapping.preset.cmdline()";
            sources = [
              {name = "path";}
              {
                name = "cmdline";
                option = {
                  ignore_cmds = ["Man" "!"];
                };
              }
            ];
          };
        };

        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
            {name = "luasnip";}
            {name = "nvim_lsp_signature_help";}
          ];

          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            "<C-Space>" = "cmp.mapping(cmp.mapping.complete(), { 'i', 'c' })";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-e>" = ''cmp.mapping.abort()'';
            "<Up>" = ''
              cmp.mapping(
                function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  else
                    fallback()
                  end
                end
              )
            '';
            "<Down>" = ''
              cmp.mapping(
                function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  else
                    fallback()
                  end
                end
              )
            '';
            "<Tab>" = "cmp.mapping.confirm({ select = true })";
          };
        };
      };
      lsp = {
        enable = true;
        onAttach = enableInlayHints;
        servers = {
          volar.enable = true;
          html = {
            enable = true;
            settings.html.format.unformatted = "wbr,span,pre,code,textarea";
            extraOptions.html.format.unformatted = "wbr,span,pre,code,textarea";
          };
          cssls.enable = true;
          lua-ls.enable = true;
          kotlin-language-server.enable = true;
          ruff-lsp = {
            enable = true;
            onAttach.function = ''
              if client.name == 'ruff_lsp' then
                -- Disable hover in favor of Pyright
                client.server_capabilities.hoverProvider = false
              end
            '';
          };
          pyright = {
            enable = true;
            package = pkgs-unstable.basedpyright;
            cmd = ["bash" "-c" "eval $(direnv export bash) && exec basedpyright-langserver --stdio"];
            extraOptions = {
              # https://github.com/astral-sh/ruff-lsp/issues/384
              capabilities = helpers.mkRaw ''
                (function()
                  local capabilities = vim.lsp.protocol.make_client_capabilities()
                  capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
                  return capabilities
                end)()
              '';
              settings = {
                pyright = {
                  disableOrganizeImports = true;
                };
              };
            };
          };
        };
      };
    };
  };
}
