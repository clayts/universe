{
  pkgs,
  lib,
  ...
}: let
  style = import ../style.nix pkgs;
in {
  programs.zed-editor = {
    enable = true;
    extensions = [
      "colored-zed-icons-theme"
      "superhtml"
      "nix"
      "color-highlight"
    ];
    package = pkgs.symlinkJoin {
      name = "zed-editor-bundle";
      paths = with pkgs; [
        zed-editor
        color-lsp
        style.fonts.sans.package
        style.fonts.mono.package
        style.fonts.emoji.package
      ];
    };
    themes.custom = ./theme.json;
    userSettings = {
      hard_tabs = true;
      git = {
        inline_blame = {
          show_commit_summary = true;
          enabled = false;
        };
      };
      git_panel = {
        dock = "right";
        status_style = "icon";
      };
      scroll_beyond_last_line = "off";
      icon_theme = "Colored Zed Icons Theme Dark";
      show_edit_predictions = false;
      project_panel = {
        indent_guides.show = "never";
        starts_open = false;
        hide_root = true;
        entry_spacing = "standard";
        dock = "right";
      };
      indent_guides.enabled = false;
      notification_panel.button = false;
      disable_ai = true;
      diagnostics.inline.enabled = true;
      terminal.button = false;
      debugger.button = false;
      outline_panel.button = false;
      collaboration_panel.button = false;
      gutter = {
        line_numbers = false;
        runnables = false;
        breakpoints = false;
        folds = false;
      };
      tab_bar = {
        show = false;
        show_nav_history_buttons = true;
        show_tab_bar_buttons = true;
      };
      toolbar = {
        breadcrumbs = true;
        quick_actions = true;
      };
      restore_on_startup = "empty_tab";
      buffer_font_family = style.fonts.mono.name;
      buffer_font_features = lib.genAttrs style.fonts.mono.features (f: true);
      buffer_font_weight = 400;
      buffer_font_size = style.fonts.mono.size * 4.0 / 3.0;
      buffer_line_height.custom = 1.19;
      ui_font_family = style.fonts.sans.name;
      ui_font_size = style.fonts.sans.size * 4.0 / 3.0;
      ui_font_weight = 400;
      soft_wrap = "none";
      preferred_line_length = 100;
      tabs.file_icons = true;
      theme = {
        mode = "dark";
        light = "Ayu Light";
        dark = "Custom";
      };
      node.path = "${pkgs.nodejs}/bin/node";
      languages = {
        Nix.language_servers = ["nixd" "!nil" "..."];
        HTML = {
          language_servers = ["superhtml" "..."];
          formatter.language_server.name = "superhtml";
        };
      };
      lsp_document_colors = "background";
      lsp = {
        nixd.settings.formatting.command = ["alejandra"];
        rust-analyzer.initialization_options.check.command = "clippy";
      };
    };
  };
}
