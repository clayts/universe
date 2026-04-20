# Universe

## To Do
- homeConfiguration = args: {...} to mirror nixosSystem = args: {...} in flake.nix
- hm
- sort out: 
	```
	home = name: initialRelease: modules: {
      homeConfigurations = {
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
