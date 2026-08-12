--ディメンション・アトラクター
-- 效果：
-- ①：自己·对方回合，自己墓地没有卡存在的场合，把这张卡从手卡送去墓地才能发动。直到下个回合的结束时，被送去墓地的卡不去墓地而除外。
function c91800273.initial_effect(c)
	-- ①：自己·对方回合，自己墓地没有卡存在的场合，把这张卡从手卡送去墓地才能发动。直到下个回合的结束时，被送去墓地的卡不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91800273,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c91800273.redcon)
	e1:SetCost(c91800273.redcost)
	e1:SetTarget(c91800273.redtg)
	e1:SetOperation(c91800273.redop)
	c:RegisterEffect(e1)
end
-- 发动条件函数：检查自己墓地是否存在卡片。
function c91800273.redcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地的卡片数量，并判断是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)==0
end
-- 发动代价函数：检查并执行将此卡送去墓地的操作。
function c91800273.redcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为效果源的此卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果靶向/发动检查函数：确认当前是否可以发动此效果（防止重复适用）。
function c91800273.redtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查当前玩家是否已经注册了该效果的标识，避免重复发动。
	if chk==0 then return Duel.GetFlagEffect(tp,91800273)==0 end
end
-- 效果处理函数：创建并注册使送去墓地的卡改去除外的全局效果，并注册发动标识。
function c91800273.redop(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下个回合的结束时，被送去墓地的卡不去墓地而除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 在全局环境注册该转移去向的效果，使其对双方玩家生效。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个持续到回合结束的标识效果，用于标记本回合已发动过此效果。
	Duel.RegisterFlagEffect(tp,91800273,RESET_PHASE+PHASE_END,0,1)
end
