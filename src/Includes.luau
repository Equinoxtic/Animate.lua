local ModulesPath = game:GetService('ReplicatedStorage');

export type AnimationData = {
	Animation: { name: string, id: number };
};

return {

	['ReplicatedStorage'] = game:GetService('ReplicatedStorage');
	['CollectionService'] = game:GetService('CollectionService');
	['ServerScriptService'] = game:GetService('ServerScriptService');
	['RunService'] = game:GetService('RunService');
	['UserInputService'] = game:GetService('UserInputService');
	['SoundService'] = game:GetService('SoundService');
	['Lighting'] = game:GetService('Lighting');
	['ContextActionService'] = game:GetService('ContextActionService');

	['Modules'] = {

		['Settings'] = ModulesPath.Game.DeveloperSettings;
		['GroupHandler'] = ModulesPath.UI.GroupHandler;

	};

};
