local AnimationBase = {};
AnimationBase.__index = AnimationBase;

local _settings = require(require(game.Workspace.Includes).Modules.Settings);

local function _warnAnimator(animator : Animator) : ()

	if (animator == nil) then
		if (_settings.DebugMode) then
			warn('Animator does not exist! Initialize with Animation:SetAnimatorComponent(...)');
		end
	end

end

function AnimationBase.New(name : string, id : number, model : Model)

	local function createAnimation(name : string, assetId : number, parent : Instance) : () -> Animation

		local newAnimation: Animation = Instance.new('Animation');
		newAnimation.Name = name or 'Animation';
		newAnimation.AnimationId = string.format('rbxassetid://%s', tostring(assetId or 000000));

		if (parent ~= nil) then
			newAnimation.Parent = parent;
		else
			newAnimation.Parent = game.Workspace;
		end

		return newAnimation;

	end

	local self = setmetatable({

		_instance = createAnimation(
			name, -- Name of the animation.
			id,   -- ID of the animation.
			model -- Parent of the animation.
		) :: Animation;

		_animator = nil :: Animator;

		_animationTrack = nil :: AnimationTrack;

	}, AnimationBase);

	return self;

end

function AnimationBase:GetAnimationComponent() : Animation

	return self._instance;

end

function AnimationBase:SetAnimatorComponent(animator : Animator) : ()

	if (animator == nil) then
		return;
	end

	self._animator = animator;

end

function AnimationBase:Preload() : ()

	if (self._animator == nil) then
		_warnAnimator(self._animator);
		return;
	end

	self._animator:LoadAnimation(self._instance);

end

function AnimationBase:GetAnimationTrack(): AnimationTrack

	if (self._animator == nil) then
		_warnAnimator(self._animator);
		return;
	end

	return self._animator:LoadAnimation(self._instance);

end

function AnimationBase:Play() : ()

	if (self._animator == nil) then
		_warnAnimator(self._animator);
		return;
	end

	self._animationTrack:Play();

end

function AnimationBase:Stop() : ()

	self._animationTrack:Stop();

end

return AnimationBase;
