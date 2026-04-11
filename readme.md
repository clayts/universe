# Universe

## To Do
- hardware stuff
	- swap play key binding to win+z
- theme colours
- include persist as proper script in nix, get rid of copying
- sort out guest background
- sort out: 
	```
	home = name: initialRelease: modules: {
      homeManagerConfigurations = {
        ${name} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};
          modules = [./home-manager] ++ modules;
        };
      };
    };
	```

## Terminal Color List
```
# black
# red
# green
# yellow
# blue
# purple
# cyan
# white
# bright-black
# bright-red
# bright-green
# bright-yellow
# bright-blue
# bright-purple
# bright-cyan
# bright-white
```
