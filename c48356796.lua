--閃光の宝札
-- 效果：
-- 只要这张卡在场上存在，自己的魔法与陷阱卡区域1处变成不能使用。这张卡以外的「闪光之宝札」在自己场上表侧表示存在的场合，自己的抽卡阶段时的通常抽卡可以抽2张卡。
function c48356796.initial_effect(c)
	-- 只要这张卡在场上存在，自己的魔法与陷阱卡区域1处变成不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c48356796.accon)
	c:RegisterEffect(e1)
	-- 这张卡以外的「闪光之宝札」在自己场上表侧表示存在的场合，自己的抽卡阶段时的通常抽卡可以抽2张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	e2:SetCondition(c48356796.drawcon)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，自己的魔法与陷阱卡区域1处变成不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetOperation(c48356796.disop)
	c:RegisterEffect(e3)
end
-- 判断这张卡能否发动：若自身为里侧表示（从场上里侧发动）需要魔陷区至少1个空格；若从手卡发动则需要至少2个空格，因为自身要占用1个区域且另有1个区域会变为不能使用。
function c48356796.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔法与陷阱区域当前可用的空格数量。
	local c=Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
	if e:GetHandler():IsFacedown() then return c>0 end
	return c>1
end
-- 过滤条件：卡名为48356796（闪光之宝札）且表侧表示。
function c48356796.filter(c)
	return c:IsCode(48356796) and c:IsFaceup()
end
-- 抽卡数增加效果的发动条件：自己魔法与陷阱区域存在其他表侧表示的「闪光之宝札」时才适用。
function c48356796.drawcon(e)
	-- 检查自己魔法与陷阱区是否存在1张满足条件的卡（即除自身外的表侧「闪光之宝札」）。
	return Duel.IsExistingMatchingCard(c48356796.filter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,e:GetHandler())
end
-- 无效区域效果的操作：选择自己魔法与陷阱区域中的1个空格设置为不能使用。
function c48356796.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使用Duel.SelectDisableField让该卡控制者从自己的魔法与陷阱区域选择1个空格，返回其位置标记作为无效区域。
	return Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
end
