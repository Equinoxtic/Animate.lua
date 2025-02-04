1. Put CharacterCustomAnimate in StarterGui. (I know it's strange, but this is really a niche and decent workaround to initialize the script once the game loads.)
	- Note: Keep the 'Includes' ModuleScript in WORKSPACE.

2. Included is a RemoteEvent called 'OverrideCharacterAnimations', put this in anywhere in
ReplicatedStorage.

- **In case this bugs out try**:

```
		[First Method]
			* Underneath 'CharacterCustomAnimate', go to 'Settings' and you should see a
			variable named 'EventPath'. Change that to the path of said RemoteEvent.

		[Second Method]
			* Manually add the followings Folders to ReplicatedStorage:
				- 'RemoteEvents' > 'Player' > [RemoteEvent]
			* Drag the RemoteEvent in the 'Player' folder.
```

3. Create a new Script in ServerScriptService and type the code in here

```lua

local OverrideCharacterAnimations = ([PathToOverrideCharacterAnimations])

game.Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAppearanceAdded:Connect(function(character: Model)
		OverrideCharacterAnimations:FireServer(player, character, {ANIMATION_LIST});
	end)
end)

```

4. Overriding animations can be as simple as...

```lua

...

game.Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAppearanceAdded:Connect(function(character: Model)
		OverrideCharacterAnimations:FireServer(player, character, {
			[Animation] = { name = NAME, id = ASSET_ID }
		})
	end)
end)

...

```

That's all for the usage guide! =)
