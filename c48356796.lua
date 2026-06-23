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
-- 判断场上是否满足激活条件，即当此卡为里侧表示时需至少有1个空魔陷区，表侧表示时需至少有2个空魔陷区。
function c48356796.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前可用的魔陷区数量。
	local c=Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
	if e:GetHandler():IsFacedown() then return c>0 end
	return c>1
end
-- 过滤函数，用于检测场上是否存在表侧表示的「闪光之宝札」。
function c48356796.filter(c)
	return c:IsCode(48356796) and c:IsFaceup()
end
-- 判断是否满足抽卡效果发动条件，即场上存在其他表侧表示的「闪光之宝札」。
function c48356796.drawcon(e)
	-- 检查以玩家来看的魔陷区是否存在至少1张满足过滤条件的「闪光之宝札」。
	return Duel.IsExistingMatchingCard(c48356796.filter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,e:GetHandler())
end
-- 无效区域操作函数，选择一个魔陷区格子使其不能使用。
function c48356796.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择一个魔陷区格子并标记为不可用。
	return Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
end
