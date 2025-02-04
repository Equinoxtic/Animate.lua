local Utility = {};

local Constants = require(script.Parent.Constants);

function Utility.StopAndDestroyAnimation(animationTrack : AnimationTrack, fadeTime : number) : ()

	if (animationTrack ~= nil) then
		animationTrack:Stop(fadeTime or Constants.DEFAULT_FADE_TIME);
		animationTrack:Destroy();
	end

end

return Utility;
