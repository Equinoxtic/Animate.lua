--[[

	* Custom 'Animate' Script for Character. (Easily reusable and can override default roblox animations.)
	* Made by @Aeronoxtic
	* Version 1.0.5
	* Date Created: 02/03/2025
	* Date Update: 02/04/2025

	- In order for this to work, you will need to copy and paste the original 'Animate' script from the player's Character.
	- After doing so, you will need to disable it so it prevents regular Roblox animations from overlapping with this system.
	- It should work normally now, and I consider this a very decent workaround.

]]

local Includes = require(game.Workspace.Includes);

local _settings = require(Includes.Modules.Settings);

local AnimationBase = require(Includes.Modules.AnimationBase);
local GroupHandler = require(Includes.Modules.GroupHandler);

local ScriptSettings = require(script.Settings);
local Utility = require(script.Utility);
local Constants = require(script.Constants);

local OverrideAnimations: RemoteEvent = ScriptSettings.EventPath;

local NoUpdateOnLoopSuccess, NoUpdateOnLoopValue = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end);

local NoUpdateOnLoop = (NoUpdateOnLoopSuccess and NoUpdateOnLoopValue);

local AnimateScaleRunSuccess, AnimateScaleRunValue = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateScaleRun")
end);

local AnimateScaleRun = (AnimateScaleRunSuccess and AnimateScaleRunValue);

local DefaultAnimationList = {
	['Idle'] = { name = 'idle', id = 107484620740391 },
	['Walk'] = { name = 'walk', id = 99177541476177 },
	['Run'] = { name = 'run', id = 99177541476177 },
	['Jump'] = { name = 'jump', id = 125750702 },
	['Fall'] = { name = 'fall', id = 180436148 },
	['Climb'] = { name = 'climb', id = 180436334 }
} :: Includes.AnimationData;

local animGroup = GroupHandler.New();

local PreloadedAnimations = {};

local CurrentAnimation: string = '';
local CurrentAnimationInstance: Animation = nil;
local CurrentAnimationTrack: AnimationTrack = nil;

local CurrentAnimationSpeed: number = 1.0;

local RunAnimationTrack = nil;

local JumpTime: number = 0.0;
local JumpDuration: number = 0.31;

local AnimationKeyFrameHandler = nil

local CurrentPose = 'Standing';

math.randomseed(tick());

local function DebugCallback(func : () -> ()) : ()
	if (_settings.DebugMode and ScriptSettings.VerboseMode) then
		func();
	end
end

local function InitializeAnimations(animationList : Includes.AnimationData, character : Model) : ()

	local Humanoid = character:WaitForChild('Humanoid');

	local InitializationThread = coroutine.create(function() -- Intializing of animations go here.

		-- Clear all preloaded animations first.

		if (_settings.DebugMode) then
			print('Clearing all Preloaded Animations for Initialization...');
		end

		PreloadedAnimations = {};

		local AnimationsFolder = Instance.new('Folder');
		AnimationsFolder.Name = 'Animations';
		AnimationsFolder.Parent = character;

		for k, v in pairs(animationList) do
			local animation = AnimationBase.New(v.name, v.id, AnimationsFolder);
			animation:SetAnimatorComponent(Humanoid:FindFirstChild('Animator'));
			animGroup:AddObject(animation, k);
			DebugCallback(function()
				print(animation);
			end);
		end

		DebugCallback(function()
			print(animGroup:GetMembers());
			print(string.format('Initialized all animations! [ %s ]', character.Name));
		end);

	end);

	coroutine.resume(InitializationThread);

	local PreloadThread = coroutine.create(function() -- Pre-loading animations go here.

		for k, v in pairs(animGroup:GetMembers()) do
			if (PreloadedAnimations[v:GetAnimationComponent().AnimationId] == nil) then
				v:Preload();
				PreloadedAnimations[v:GetAnimationComponent().AnimationId] = true;
				--[[DebugCallback(function()
					print(PreloadedAnimations[v:GetAnimationComponent().AnimationId]);
				end);]]
			end
		end

		if (_settings.DebugMode) then
			print(string.format('Preloaded all animations! [ %s ]', character.Name));
		end

	end);

	coroutine.resume(PreloadThread);

end

local function ClearAnimations() : ()

	for k, v in pairs(animGroup:GetMembers()) do
		animGroup:RemoveObject(k);
	end

end

local function SwitchAnimation(animation : Animation, animationName : string, speed : number, fadeTime : number) : ()

	if (animation ~= CurrentAnimationInstance) then

		if (CurrentAnimationTrack ~= nil)  then
			Utility.StopAndDestroyAnimation(CurrentAnimationTrack, fadeTime);
		end

		if (RunAnimationTrack ~= nil) then
			Utility.StopAndDestroyAnimation(RunAnimationTrack, fadeTime);
			if (NoUpdateOnLoop == true) then
				RunAnimationTrack = nil;
			end
		end

		CurrentAnimationSpeed = 1.0;

		CurrentAnimationTrack = animGroup:GetObject(animationName):GetAnimationTrack();
		CurrentAnimationTrack.Priority = Enum.AnimationPriority.Core;

		CurrentAnimationTrack:Play(fadeTime);
		CurrentAnimationInstance = animation;
		CurrentAnimation = animationName;

		if (speed ~= nil and speed <= 0) then
			CurrentAnimationTrack:AdjustSpeed(speed);
			CurrentAnimationSpeed = speed;
		end

		if (animationName == 'Walk') then

			RunAnimationTrack = animGroup:GetObject('Run'):GetAnimationTrack();
			RunAnimationTrack.Priority = Enum.AnimationPriority.Core;
			RunAnimationTrack:Play();

		end

	end

end

local function PlayAnimation(key : string, speed : number, fadeTime : number) : ()
	if (animGroup:GetObject(key) ~= nil) then
		SwitchAnimation(animGroup:GetObject(key):GetAnimationTrack(), key, speed, fadeTime or Constants.DEFAULT_FADE_TIME);
	else
		if (_settings.DebugMode) then
			warn(string.format('Failed to play animation! - [%s]', key));
		end
	end
end

local function StopAllAnimations()

	local OldAnimation = CurrentAnimation;

	CurrentAnimation = '';
	CurrentAnimationInstance = nil;
	if (CurrentAnimationTrack ~= nil) then
		Utility.StopAndDestroyAnimation(CurrentAnimationTrack, 0.0);
		CurrentAnimationTrack = nil;
	end

	if (RunAnimationTrack) then
		Utility.StopAndDestroyAnimation(RunAnimationTrack, 0.0);
		RunAnimationTrack = nil;
	end

	return OldAnimation;

end

OverrideAnimations.OnClientEvent:Connect(function(character: Model, animationList : {[string]: {name: string, id: number}}) : ()

	--[[
		* Added this check, just in case if anything fails.
	]]
	if (character ~= nil) then
		script.Parent = character;
	else
		error('Failed overriding animations.');
		return;
	end

	local Humanoid: Humanoid = character:WaitForChild('Humanoid');

	ClearAnimations(); -- Clear current animation group so that it doesn't conflict with any future existing animations.
	InitializeAnimations(animationList or DefaultAnimationList, character);

	local function GetRigScale() : number
		if (AnimateScaleRun) then
			return character:GetScale();
		else
			return 1.0;
		end
	end

	local function GetHeightScale(humanoid : Humanoid) : number

		local function CalculateHipHeight(value : number, dampeningPercentage : number) : number
			return (1.0 + (humanoid.HipHeight / value) * dampeningPercentage / value);
		end

		if (humanoid) then

			if (not humanoid.AutomaticScalingEnabled) then
				return GetRigScale();
			end

			local HUMANOID_HIP_HEIGHT: number = 2.0;

			local Scale: number = humanoid.HipHeight / HUMANOID_HIP_HEIGHT;
			Scale = CalculateHipHeight(HUMANOID_HIP_HEIGHT, Constants.ScaleDampeningPercent);

			return Scale;

		end

		return 1.0;

	end

	local lastTick: number = 0;

	local function StepAnimate(t : number) : () -> ()

		local deltaTime: number = t - lastTick;
		lastTick = t;

		local setAngles: boolean = false;

		if (JumpTime > 0.0) then
			JumpTime = JumpTime - deltaTime;
		end

		if (CurrentPose == 'FreeFall' and JumpTime <= 0) then
			PlayAnimation('Fall', 1.0, 0.2)
		elseif (CurrentPose == 'Walking') then
			PlayAnimation('Walk', 1.0, 0.1);
		elseif (CurrentPose == 'Dead' or CurrentPose == 'PlatformStanding' or CurrentPose == 'GettingUp' or CurrentPose == 'FallingDown' or CurrentPose == 'Seated') then
			StopAllAnimations();
		end

		DebugCallback(function()

			local s: string = string.format('Stepping : %d | %s', lastTick, CurrentPose);

			if (ScriptSettings.LimitedStepMode) then
				local mod = math.round(lastTick % ScriptSettings.StepLimit);
				if (mod == 0) then
					print(s);
				end
			else
				print(s);
			end

		end);

	end

	--[[
		Humanoid State changes.
	]]

	Humanoid.Died:Connect(function()
		CurrentPose = 'Dead';
	end);

	Humanoid.Running:Connect(function(speed : number) : () -> ()

		local HEIGHT_SCALE = if (AnimateScaleRun) then
			GetHeightScale(Humanoid) else 1.0;

		local Moved = Humanoid.MoveDirection == Vector3.new(0, 0, 0);
		local SpeedThreshold = Moved and (Humanoid.WalkSpeed / HEIGHT_SCALE) or 0.75;

		if (speed > SpeedThreshold * HEIGHT_SCALE) then
			local SCALE = 16.0;
			PlayAnimation('Walk', (speed / SCALE), 0.2);
			CurrentPose = 'Running';
		else
			PlayAnimation('Idle', 1.0, 0.1);
			CurrentPose = 'Standing';
		end

	end);

	--[[
		Using Humanoid:GetPropertyChangedSignal('Jump') instead of Humanoid.Jumping, since Humanoid.Jumping
		is apparently read-only and cannot be detected properly.
	]]
	Humanoid:GetPropertyChangedSignal('Jump'):Connect(function()
		PlayAnimation('Jump', 1.0, 0.2);
		JumpTime = JumpDuration;
		CurrentPose = 'Jumping';
	end);

	Humanoid.Climbing:Connect(function(speed: number)
		if AnimateScaleRun then
			speed /= GetHeightScale();
		end
		local scale = 5.0;
		PlayAnimation('Climb', (speed / scale), 0.2);
		CurrentPose = 'Climbing';
	end);

	Humanoid.GettingUp:Connect(function()
		CurrentPose = 'GettingUp';
	end);

	Humanoid.FreeFalling:Connect(function()
		if (JumpTime <= 0.0) then
			PlayAnimation('Fall', 1.0, 0.2);
		end
		CurrentPose = 'FreeFall';
	end);

	Humanoid.FallingDown:Connect(function()
		CurrentPose = 'FallingDown';
	end)

	Humanoid.Seated:Connect(function()
		CurrentPose = 'Seated';
	end);

	Humanoid.PlatformStanding:Connect(function()
		CurrentPose = 'PlatformStanding';
	end);

	-- Initialize to Idle Animation.
	if (character.Parent ~= nil) then
		PlayAnimation('Idle', 1.0, 0.1);
		CurrentPose = 'Standing';
	end

	-- Separating this into a coroutine thread(?)
	local StepAnimateThread = coroutine.create(function(ticks)
		while character.Parent ~= nil do
			local _, gameTime = wait(ticks);
			StepAnimate(gameTime);
		end
	end);

	coroutine.resume(StepAnimateThread, 0.1);

	if (_settings.DebugMode) then
		print(string.format('Initialized new Animate script for character! [ %s ]', character.Name));
	end

end);
