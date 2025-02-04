local GroupHandler = {};
GroupHandler.__index = GroupHandler;

function GroupHandler.New() : () -> any

	local self = setmetatable({
		Group = {} :: {[string] : any}
	}, GroupHandler);

	return self;

end

function GroupHandler:AddObject(o : any, key : string) : ()

	if (o == nil) then
		return;
	end

	self.Group[key] = o;

end

function GroupHandler:GetObject(key : string) : any

	if (self.Group[key] ~= nil) then
		return self.Group[key];
	end

end

function GroupHandler:RemoveObject(key : string) : ()

	if (self.Group[key] ~= nil) then
		self.Group[key] = nil;
	end

end

function GroupHandler:GetMembers() : any

	return self.Group;

end

return GroupHandler;
